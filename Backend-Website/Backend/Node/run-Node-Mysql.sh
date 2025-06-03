echo ===== Setting up Node.js Backend Mysql =====
@echo off
:: define a unique file name 

:: Enable delayed variable expansion
setlocal EnableDelayedExpansion

:: Get date parts
for /f "tokens=2-4 delims=/ " %%a in ("%date%") do (
    set month=%%a
    set day=%%b
    set year=%%c
) 

:: Get date parts
for /f "tokens=2-4 delims=/ " %%a in ("%date%") do (
    set month=%%a
    set day=%%b
    set year=%%c
)

:: Get time parts
for /f "tokens=1-4 delims=:.," %%a in ("%time%") do (
    set hour=%%a
    set min=%%b
    set sec=%%c
    set ms=%%d
)

:: Remove spaces (some systems pad hour with space)
set hour=%hour: =%
set min=%min: =%
set sec=%sec: =%
set ms=%ms: =%

:: Add leading zeros if needed
if %hour% LSS 10 set hour=0%hour%
if %min% LSS 10 set min=0%min%
if %sec% LSS 10 set sec=0%sec%
if %ms% LSS 100 set ms=0%ms%
if %ms% LSS 10 set ms=00%ms%

:: Build timestamp
set timestamp=%year%%month%%day%_%hour%%min%%sec%%ms%


:: Define the backend folder
set BACKEND_DIR="%~dp0\..\..\projet\backend_%timestamp%"
:: Define the Config and Routes directories
set CONFIG_DIR=%BACKEND_DIR%\Config
set ROUTES_DIR=%BACKEND_DIR%\Routes
:: Define file paths for Services.js, dbConnection.js, Routes.js and index.js
set SERVICE_FILE=%CONFIG_DIR%\services.js
set DB_FILE=%CONFIG_DIR%\dbConnection.js
set ROUTE_FILE=%ROUTES_DIR%\routes.js
set INDEX_FILE=%BACKEND_DIR%\index.js
::----------------------------------------------------
:: Check if Node.js is installed
node -v >nul 2>&1
if %errorlevel% neq 0 (
    echo Node.js is not installed! Please download it here: https://nodejs.org/
    exit /b
)
::---------------------------------------------------
:: Create the backend folder
if not exist "%BACKEND_DIR%" (
    mkdir "%BACKEND_DIR%"
    echo Backend folder created.
) else (
    echo Backend folder already exists.
)
:: Create the Config folder
if not exist "%CONFIG_DIR%" (
    mkdir "%CONFIG_DIR%"
    echo Config folder created.
) else (
    echo Config folder already exists.
)
:: Create the Routes  folder
if not exist "%ROUTES_DIR%" (
    mkdir "%ROUTES_DIR%"
    echo Routes folder created.
) else (
    echo Routes folder already exists.
)
::--------------------------------------------------------
:: Capture parameters
set "DB_URI=%~1"
set "DB_NAME=%~2"
set "USERNAME=%~3"
set "PASSWORD=%~4"
set "PORT=%~5"
::--------------------------------------------------------
:: Debugging: Print values to confirm they are correct 
echo DB URI: %DB_URI%
echo Database Name: %DB_NAME%
echo Username: %USERNAME%
echo Password: %PASSWORD%
echo port: %PORT%
::--------------------------------------------------------
:: Create package.json
echo Creating package.json...
echo { > "%BACKEND_DIR%\package.json"
echo   "name": "backend", >> "%BACKEND_DIR%\package.json"
echo   "version": "1.0.0", >> "%BACKEND_DIR%\package.json"
echo   "main": "index.js", >> "%BACKEND_DIR%\package.json"
echo   "scripts": { >> "%BACKEND_DIR%\package.json"
echo     "start": "node index.js" >> "%BACKEND_DIR%\package.json"
echo   }, >> "%BACKEND_DIR%\package.json"
echo   "dependencies": { >> "%BACKEND_DIR%\package.json"
echo     "express": "^4.18.2", >> "%BACKEND_DIR%\package.json"
echo     "mysql2": "^3.14.1", >> "%BACKEND_DIR%\package.json"
echo     "cors": "^2.8.5" >> "%BACKEND_DIR%\package.json"
echo   } >> "%BACKEND_DIR%\package.json"
echo } >> "%BACKEND_DIR%\package.json"
::---------------------------------------------------------
:: Creating index.js
echo Creating index.js...
echo const express = require('express');>> "%INDEX_FILE%"
echo const cors = require('cors'); >> "%INDEX_FILE%"
echo const apiRoutes = require('./Routes/routes.js');>> "%INDEX_FILE%"
echo const app = express();>> "%INDEX_FILE%"
echo // Active CORS >> "%INDEX_FILE%"
echo app.use(cors()); >> "%INDEX_FILE%"
echo app.use(express.json()); >> "%INDEX_FILE%"
echo app.use('/api', apiRoutes); >> "%INDEX_FILE%"
echo app.listen(3000, () =^>{ console.log('Server running on http://localhost:3000');});>> "%INDEX_FILE%"   
::------------------------------------------------
::creating dbConnection.js
echo const mysql = require('mysql2/promise');>>"%DB_FILE%"
echo // Static credentials (empty if none)>>"%DB_FILE%"
echo const USER = '%USERNAME%', PASS = '%PASSWORD%';>>"%DB_FILE%"
echo let connection; >>"%DB_FILE%"
echo   // Include "user:pass@" only when both are non-empty>>"%DB_FILE%"
echo async function connect({host='%DB_URI%', port= %PORT% , dbName='%DB_NAME%'}) {>>"%DB_FILE%"
echo   const auth = USER ^&^& PASS ^? `^${USER}:^${PASS}^@` : ''; >>"%DB_FILE%"
echo   try {>>"%DB_FILE%"
echo     if (connection ^&^& connection.connection ^&^& connection.connection.state ^!== 'disconnected') { >>"%DB_FILE%"
echo       return connection; >>"%DB_FILE%"
echo     }>>"%DB_FILE%"
echo     console.log(`→ Connecting to MySQL at ^${host}:^${port}, database: ^${dbName}`);>>"%DB_FILE%"
echo     connection = await mysql.createConnection({host,port,user: USER ^|^| 'root',password: PASS ^|^| '',database: dbName}); >>"%DB_FILE%"
echo     console.log('→ MySQL connection established');>>"%DB_FILE%"
echo     return connection; >>"%DB_FILE%"
echo   } catch (err) {>>"%DB_FILE%"
echo     console.error('Connection failed:', err);>>"%DB_FILE%"
echo     throw err; >>"%DB_FILE%"
echo   }>>"%DB_FILE%"
echo }>>"%DB_FILE%"
echo module.exports = { connect };>>"%DB_FILE%"
echo dbConnection.js created 
echo index.js created.
::----------------------------------------
::creating Services.js File:
echo Creating Services.js...
echo const { connect } = require('./dbConnection.js'); // import connect function >>"%SERVICE_FILE%"
echo // Fetch all data from all tables >>"%SERVICE_FILE%"
echo async function fetchData() {>>"%SERVICE_FILE%"
echo   const conn = await connect({ host:'%DB_URI%', port: %PORT% , dbName: '%DB_NAME%' }); >>"%SERVICE_FILE%"
echo   const [tables] = await conn.query("SHOW TABLES"); >>"%SERVICE_FILE%"
echo   const data = {};>>"%SERVICE_FILE%"
echo   for (const row of tables) {>>"%SERVICE_FILE%"
echo     const tableName = Object.values(row)[0];>>"%SERVICE_FILE%"
echo     const [rows] = await conn.query(`SELECT * FROM \`${tableName}\``);>>"%SERVICE_FILE%"
echo     const formattedRows = rows.map(item =^> { >>"%SERVICE_FILE%"
echo     if ('id' in item) { >>"%SERVICE_FILE%"
echo         const { id, ...rest } = item;>>"%SERVICE_FILE%"
echo         return { ...rest, _id: id }; >>"%SERVICE_FILE%"
echo     } >>"%SERVICE_FILE%"
echo     return item; >>"%SERVICE_FILE%"
echo  });>>"%SERVICE_FILE%"
echo  data[tableName] = formattedRows; >>"%SERVICE_FILE%"
echo  } >>"%SERVICE_FILE%"
echo  return data;  >>"%SERVICE_FILE%"
echo }>>"%SERVICE_FILE%"
echo // Fetch all table names>>"%SERVICE_FILE%"
echo async function getTableNames() {>>"%SERVICE_FILE%"
echo   const conn = await connect({ host:'%DB_URI%', port: %PORT% , dbName: '%DB_NAME%' });>>"%SERVICE_FILE%"
echo   const [results] = await conn.query('SHOW TABLES');>>"%SERVICE_FILE%"
echo   return results.map(row =^> Object.values(row)[0]);>>"%SERVICE_FILE%"
echo } >>"%SERVICE_FILE%"
echo // Fetch a single item by its ID from a specific table >>"%SERVICE_FILE%"
echo async function getItemById(table, id) {>>"%SERVICE_FILE%"
echo   const conn = await connect({ host:'%DB_URI%', port: %PORT% , dbName: '%DB_NAME%' }); >>"%SERVICE_FILE%"
echo   const [rows] = await conn.query(`SELECT * FROM \`${table}\` WHERE id = ?`, [id]); >>"%SERVICE_FILE%"
echo   if (rows[0]) { >>"%SERVICE_FILE%"
echo      const { id, ...rest } = rows[0]; >>"%SERVICE_FILE%"
echo      return { ...rest, _id: id };>>"%SERVICE_FILE%"
echo   } >>"%SERVICE_FILE%"
echo   return null; >>"%SERVICE_FILE%"
echo }>>"%SERVICE_FILE%"
echo // Update a specific item by its ID>>"%SERVICE_FILE%"
echo async function updateItemById(table, id, updateFields) { >>"%SERVICE_FILE%"
echo   const conn = await connect({ host:'%DB_URI%', port: %PORT% , dbName: '%DB_NAME%' });>>"%SERVICE_FILE%"
echo   const keys = Object.keys(updateFields);>>"%SERVICE_FILE%"
echo   const values = Object.values(updateFields);>>"%SERVICE_FILE%"
echo const cleanKeys = [^]; >>"%SERVICE_FILE%"
echo const cleanValues = [^];>>"%SERVICE_FILE%"
echo for (let i = 0; i ^< keys.length; i^+^+) {>>"%SERVICE_FILE%"
echo   if (keys[i] ^!== '_id') {>>"%SERVICE_FILE%"
echo     cleanKeys.push(keys[i]); >>"%SERVICE_FILE%"
echo     cleanValues.push(values[i]);>>"%SERVICE_FILE%"
echo   }>>"%SERVICE_FILE%"
echo }>>"%SERVICE_FILE%"
echo   if (cleanKeys.length === 0) return null;>>"%SERVICE_FILE%"
echo   const setClause = cleanKeys.map(key =^> `\`^${key}\` = ?`).join(', ');>>"%SERVICE_FILE%"
echo   const sql = `UPDATE \`${table}\` SET ${setClause} WHERE id = ?`; >>"%SERVICE_FILE%"
echo   const [result] = await conn.query(sql, [...cleanValues, id]);  >>"%SERVICE_FILE%"            
echo   return result; >>"%SERVICE_FILE%"
echo }>>"%SERVICE_FILE%"
echo // Delete an item by its ID >>"%SERVICE_FILE%"
echo async function deleteItemById(table, id) { >>"%SERVICE_FILE%"
echo   const conn = await connect({ host:'%DB_URI%', port: %PORT% , dbName: '%DB_NAME%' });>>"%SERVICE_FILE%"
echo   const [result] = await conn.query(`DELETE FROM ^\`^${table}\` WHERE id = ^?`, [id]);>>"%SERVICE_FILE%"
echo   return result; >>"%SERVICE_FILE%" 
echo }>>"%SERVICE_FILE%"
echo // Drop a complete table from the database>>"%SERVICE_FILE%"
echo async function deleteTableByName(tableName) {>>"%SERVICE_FILE%"
echo   const conn = await connect({ host:'%DB_URI%', port: %PORT% , dbName: '%DB_NAME%' });>>"%SERVICE_FILE%"
echo   const [result] = await conn.query(`DROP TABLE ^\`^${tableName}^\``);>>"%SERVICE_FILE%"
echo   return result; >>"%SERVICE_FILE%"
echo }>>"%SERVICE_FILE%"
echo module.exports = {fetchData,getTableNames, getItemById,updateItemById,deleteItemById,deleteTableByName,}; >>"%SERVICE_FILE%"
echo services.js created
::--------------------------------------------------------------------------------
::creating Routes.js
echo const express = require('express');>> "%ROUTE_FILE%"
echo const router = express.Router(^);>> "%ROUTE_FILE%"
echo const {fetchData, getTableNames, getItemById, updateItemById,deleteItemById,deleteTableByName,} = require('../Config/services');>> "%ROUTE_FILE%"
echo router.get('/getall', async (req, res) =^> { >> "%ROUTE_FILE%"
echo   try {>> "%ROUTE_FILE%"
echo     const data = await fetchData();>> "%ROUTE_FILE%"
echo     res.json(data); >> "%ROUTE_FILE%"
echo   } catch (err) { >> "%ROUTE_FILE%"
echo     console.error('Error fetching data:', err); >> "%ROUTE_FILE%"
echo     res.status(500).json({ error: 'Server error while fetching data' }); >> "%ROUTE_FILE%"
echo   }>> "%ROUTE_FILE%"
echo });>> "%ROUTE_FILE%"
echo //route to get the table names>> "%ROUTE_FILE%"
echo router.get('/tablenames', async (req, res) =^> {>> "%ROUTE_FILE%"
echo   try {>> "%ROUTE_FILE%"
echo     const names = await getTableNames();>> "%ROUTE_FILE%"
echo     console.log(names); //log names to see them >> "%ROUTE_FILE%"
echo     res.json(names);>> "%ROUTE_FILE%"
echo   } catch (err) {>> "%ROUTE_FILE%"
echo     console.error('Error fetching table names:', err);>> "%ROUTE_FILE%"
echo     res.status(500).json({ error: 'Server error while fetching table names' });>> "%ROUTE_FILE%"
echo   }>> "%ROUTE_FILE%"
echo });>> "%ROUTE_FILE%"
echo //route to view an item with its id>> "%ROUTE_FILE%"
echo router.get('/:table/:id', async (req, res) =^> {>> "%ROUTE_FILE%"
echo   const { table, id } = req.params;>> "%ROUTE_FILE%"
echo   try {>> "%ROUTE_FILE%"
echo     const item = await getItemById(table, id);>> "%ROUTE_FILE%"
echo       if ^(^^^!item^^^) {>> "%ROUTE_FILE%"
echo         return res.status(404).json({ error: 'Item not found' });>> "%ROUTE_FILE%"
echo       }>> "%ROUTE_FILE%"
echo       res.json(item);>> "%ROUTE_FILE%"
echo     } catch (err) {>> "%ROUTE_FILE%"
echo       res.status(500).json({ error: 'Internal Server Error' });>> "%ROUTE_FILE%"
echo     }>> "%ROUTE_FILE%"
echo   });>> "%ROUTE_FILE%"
echo //rouute to update an item>> "%ROUTE_FILE%"
echo router.put('/update/:table/:id', async (req, res) =^> {>> "%ROUTE_FILE%"
echo const { table, id } = req.params; >> "%ROUTE_FILE%"
echo     try {>> "%ROUTE_FILE%"
echo       const result = await updateItemById(table, id, req.body); >> "%ROUTE_FILE%"
echo       res.json({ success: result.affectedRows > 0, result });>> "%ROUTE_FILE%"
echo     } catch (err) {>> "%ROUTE_FILE%"
echo       console.error('Error updating item:', err);>> "%ROUTE_FILE%"
echo       res.status(500).json({ error: 'Server error while updating item' });>> "%ROUTE_FILE%"
echo     }>> "%ROUTE_FILE%"
echo });>> "%ROUTE_FILE%"
echo  //route to delete an item>> "%ROUTE_FILE%"
echo  router.delete('/delete/:table/:id', async (req, res) =^> {>> "%ROUTE_FILE%"
echo    const { table, id } = req.params; >> "%ROUTE_FILE%"
echo    try { >> "%ROUTE_FILE%"
echo      const result = await deleteItemById(table, id);>> "%ROUTE_FILE%"
echo      res.json({ success: result.affectedRows > 0 });>> "%ROUTE_FILE%"
echo      } catch (err) {>> "%ROUTE_FILE%"
echo        console.error('Error deleting item:', err); >> "%ROUTE_FILE%"
echo        res.status(500).json({ error: 'Server error while deleting item' }); >> "%ROUTE_FILE%"
echo   }>> "%ROUTE_FILE%"
echo });>> "%ROUTE_FILE%"
echo //route to delete a TABLE >> "%ROUTE_FILE%"
echo router.delete('/delete/:table', async (req, res) =^> {>> "%ROUTE_FILE%"
echo   const { table } = req.params;>> "%ROUTE_FILE%"
echo   try {>> "%ROUTE_FILE%"
echo     await deleteTableByName(table);>> "%ROUTE_FILE%"
echo     res.json({ success: true, message: `Table ^${table} deleted successfully` });>> "%ROUTE_FILE%"
echo   } catch (err) {>> "%ROUTE_FILE%"
echo     console.error('Error deleting table:', err);>> "%ROUTE_FILE%"
echo     res.status(500).json({ error: 'Server error while deleting table' }); >> "%ROUTE_FILE%"
echo   }>> "%ROUTE_FILE%"
echo });>> "%ROUTE_FILE%"
echo module.exports = router;>> "%ROUTE_FILE%"
echo routes.js created
::-------------------------------------------------------
cd /d "%BACKEND_DIR%"
echo // Installing dependencies, please wait!
:: Run npm install 
call npm install express mysql2 cors
echo Dependencies installed successfully!
:: Define script path
set "SCRIPT_PATH=%~dp0\..\..\projet\backend_%timestamp%"
:: Check if index.js exists
if not exist "%SCRIPT_PATH%" (
    echo Script file not found: %SCRIPT_PATH%
    exit /b
)
:: Start the Node.js server
echo Starting the Node.js server...
start node index.js

echo Server is running at http://localhost:3000