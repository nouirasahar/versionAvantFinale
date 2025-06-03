import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { saveAs } from 'file-saver';

@Injectable({
  providedIn: 'root',
})
export class DownloadService {
  constructor(private http: HttpClient) {}

downloadFile(id: string, token: string) {
  const fileUrl = `http://localhost:5000/zip-download/${id}/${token}`;
  this.http.get(fileUrl, {
    responseType: 'blob',
  }).subscribe((response) => {
    const filename = `projet_${id}.zip`;
    saveAs(response, filename);
  }, error => {
    console.error('Download error:', error);
  });
}
}
