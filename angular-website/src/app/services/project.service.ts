import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import{ saveAs } from 'file-saver';
@Injectable({
  providedIn: 'root'
})
export class ProjectService {
  private apiUrl = 'http://localhost:5000/api/generate-project';
  private selectedTechStack: any = null;

  constructor(private http: HttpClient) { }

  setTechStack(techStack: any) {
    this.selectedTechStack = techStack;
  }

  generateProject(dbConfig: any): Observable<any> {
    const projectData = {
      frontend: this.selectedTechStack?.frontend,
      backend: this.selectedTechStack?.backend,
      host: dbConfig.host,
      dbName: dbConfig.dbName,
      username: dbConfig.username,
      password: dbConfig.password,
      port: dbConfig.port,
      TypeDB: this.selectedTechStack?.database
    };

    console.log('Sending to backend:', projectData);
    console.log('Backend URL:', this.apiUrl);

    return this.http.post(this.apiUrl, projectData);
  }
}
