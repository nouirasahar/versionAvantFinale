import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router, RouterLink } from '@angular/router';
import { ReactiveFormsModule, FormBuilder, FormGroup, Validators } from '@angular/forms';
import { ProjectService } from '../../services/project.service';

@Component({
  selector: 'app-database-configuration',
  standalone: true,
  imports: [CommonModule, RouterLink, ReactiveFormsModule],
  templateUrl: './database-configuration.component.html',
  styleUrls: ['./database-configuration.component.css']
})
export class DatabaseConfigurationComponent {
  databaseForm: FormGroup;
  errorMessage: string = '';
  isLoading = false;

  constructor(
    private router: Router,
    private projectService: ProjectService,
    private fb: FormBuilder
  ) {
    this.databaseForm = this.fb.group({
      username: ['', Validators.required],
      password: ['', Validators.required],
      host: ['', Validators.required],
      port: [''], // Optional
      dbName: ['', Validators.required]
    });
  }

  goBack() {
    this.router.navigate(['/get-started']);
  }

  isFieldInvalid(field: string): boolean {
    const control = this.databaseForm.get(field);
    return !!(control && control.invalid && (control.dirty || control.touched));
  }

  generateProject() {
    if (this.databaseForm.invalid) {
      this.errorMessage = 'Veuillez remplir tous les champs obligatoires (Username, Password, Host, Database Name).';
      this.databaseForm.markAllAsTouched();
      return;
    }
    this.errorMessage = '';
    this.isLoading = true;
    const config = this.databaseForm.value;
    this.projectService.generateProject(config).subscribe({
    next: (response) => {
    this.isLoading = false;

    // Calcul de l'expiration (dans 30 minutes)
    const expiresAt = Date.now() + 30 * 60 * 1000;
    localStorage.setItem('uniqueId', response.uniqueId);
    localStorage.setItem('token', response.token);
    localStorage.setItem('expiresAt', expiresAt.toString());

    this.router.navigate(['/generate-project'], {
      state: {
        uniqueId: response.uniqueId,
        token: response.token
      }
    });
  }
  });
  }
}
