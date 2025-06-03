// Requires
const express = require("express");
const { exec } = require("child_process");
const path = require("path");
const cors = require('cors');
const archiver = require('archiver');
require('dotenv').config();
const { MongoClient } = require('mongodb');
const fs = require('fs');
const crypto = require('crypto');

const app = express();
const PORT = process.env.PORT || 5000;
app.use(express.json());
app.use(cors());
app.use('/downloads', express.static(path.join(__dirname, 'public')));

// Génère et sert immédiatement le .zip à l'utilisateur
app.get('/zip-download/:id/:token', (req, res) => {
    const { id, token } = req.params;
    const secret = process.env.DOWNLOAD_SECRET || 'supersecret';
    const expectedToken = crypto.createHmac('sha256', secret).update(id).digest('hex');

    if (token !== expectedToken) {
        return res.sendStatus(403);
    }

    const projectDir = path.join(__dirname, 'generated', id);
    if (!fs.existsSync(projectDir)) {
        return res.sendStatus(404);
    }

    // Créer un nouveau fichier ZIP
    const archive = archiver('zip', {
        zlib: { level: 9 } // Niveau de compression maximum
    });

    // Gérer les erreurs de l'archive
    archive.on('error', (err) => {
        console.error('Erreur lors de la création du ZIP:', err);
        res.status(500).send('Erreur lors de la création du fichier ZIP');
    });

    // Définir le nom du fichier ZIP
    res.attachment(`project-${id}.zip`);

    // Pipe l'archive vers la réponse
    archive.pipe(res);

    // Ajouter le contenu du dossier au ZIP
    archive.directory(projectDir, false);

    // Finaliser l'archive
    archive.finalize();
});

app.post("/api/generate-project", async (req, res) => {
    const { frontend, backend, host, dbName, username, password, TypeDB, port } = req.body;
    console.log("Received POST request...");
    console.log("Parameters received:", { backend, host, dbName, username, password, frontend, port });
    const scriptPath = path.join(__dirname, "Backend", `${backend}`, `run-${backend}-${TypeDB}.sh`);
    const scriptPath2 = path.join(__dirname, "Frontend", `${frontend}`, `run-${frontend}.sh`);

    const uniqueId = Date.now() + '-' + Math.random().toString(36).substring(2, 10);
    const secret = process.env.DOWNLOAD_SECRET || 'supersecret';
    const token = crypto.createHmac('sha256', secret).update(uniqueId).digest('hex');
    const generatedBaseDir = path.join(__dirname, 'generated');
    const projectDir = path.join(generatedBaseDir, uniqueId);
    fs.mkdirSync(projectDir, { recursive: true });

    if (TypeDB && TypeDB.toLowerCase().includes('mongo')) {
        const auth = `${username}:${password}@`;
        const uri = `mongodb+srv://${auth}${host}/${dbName}?retryWrites=true&w=majority`;
        try {
            const client = new MongoClient(uri);
            await client.connect();
            await client.db(dbName).command({ ping: 1 });
            await client.close();
            console.log('MongoDB connection successful.');
        } catch (err) {
            console.error('MongoDB connection failed:', err.message);
            return res.status(400).json({ message: 'Database connection failed' });
        }
    }

    // Promesse pour exécuter le script backend
    const backendPromise = new Promise((resolve) => {
        if (backend) {
            const command = `bash ${scriptPath} "${host}" "${dbName}" "${username}" "${password}" "${port}" "${projectDir}" `;
            console.log(`Executing backend command: ${command}`);
            exec(command, (err, stdout, stderr) => {
                if (err) {
                    console.error("Error executing backend script:", err.message);
                }
                console.log("Backend Script executed (background).\nBatch Script Output:\n", stdout || stderr);
                resolve(); // Résolution une fois terminé
            });
        } else {
            resolve(); // Rien à faire si pas de backend
        }
    });

    // Promesse pour exécuter le script frontend (avec délai)
    const frontendPromise = new Promise((resolve) => {
        if (frontend) {
            setTimeout(() => {
                const command = `bash ${scriptPath2} "${projectDir}" `;
                console.log(`Executing frontend command: ${command}`);
                exec(command, { cwd: path.dirname(scriptPath2) }, (err, stdout, stderr) => {
                    if (err) {
                        console.error("Error executing frontend script:", err.message);
                    }
                    console.log("Frontend Script executed (background).\nBatch Script Output:\n", stdout || stderr);
                    resolve(); // Résolution une fois terminé
                });
            }, 35000); // Attente de 35 secondes
        } else {
            resolve(); // Rien à faire si pas de frontend
        }
    });


    Promise.all([backendPromise, frontendPromise])
    .then(() => console.log(`Project generated at ${projectDir}`))
    .catch(err => console.error('Error during project generation:', err));
    // Répond immédiatement au frontend
    return res.json({ message: "Project generation started.", uniqueId, token });
});
app.get('/hello', (req, res) => {
  res.send('Hello World!');
});

// Nettoyage automatique des anciens projets générés (plus d'1h)
const generatedDir = path.join(__dirname, 'generated');

const cleanupOldProjects = () => {
    console.log('Starting cleanup of old projects...');
    
    // Vérifier si le dossier existe
    if (!fs.existsSync(generatedDir)) {
        console.log(' The generated folder n\ does not exist ');
        return;
    }

    fs.readdir(generatedDir, (err, files) => {
        if (err) {
            console.error('Error reading the folder:', err);
            return;
        }

        if (files.length === 0) {
            console.log('No projects to clean');
            return;
        }

        files.forEach(dir => {
            const dirPath = path.join(generatedDir, dir);
            
            fs.stat(dirPath, (err, stats) => {
                if (err) {
                    console.error(`Error reading stats for deleting project ${dir}:`, err);
                    return;
                }

                const fileAge = Date.now() - stats.ctimeMs;
                const thirtyMinutes = 30 * 60 * 1000; // 30 minutes en millisecondes

                if (fileAge > thirtyMinutes) {
                    console.log(`Error while deleting ${dir} (age: ${Math.round(fileAge/1000/60)} minutes)`);
                    
                    fs.rm(dirPath, { recursive: true, force: true }, (err) => {
                        if (err) {
                            console.error(`Error while deleting ${dir}:`, err);
                        } else {
                            console.log(`Project ${dir} successfully deleted`);
                        }
                    });
                }
            });
        });
    });
};

// Exécuter le nettoyage immédiatement au démarrage
cleanupOldProjects();

// Puis exécuter toutes les 30 minutes
setInterval(cleanupOldProjects, 30 * 60 * 1000);

app.listen(PORT, () => console.log(`Running:http://localhost:${PORT}/`));