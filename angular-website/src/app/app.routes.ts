import { Routes } from '@angular/router';
import { HomeComponent } from './components/home/home.component';
import { DatabaseConfigurationComponent } from './components/DatabaseConfiguration/database-configuration.component';
import { TechChoosingComponent } from './components/tech-choosing/tech-choosing.component';
import { GenerateProjectComponent } from './components/generate-project/generate-project.component';

export const routes: Routes = [
  { path: '', component: HomeComponent },
  { path: 'database-configuration', component: DatabaseConfigurationComponent },
  { path: 'generate-project', component: GenerateProjectComponent },
  { path: 'deployment', component: HomeComponent },
  { path: 'get-started', component: TechChoosingComponent },
  { path: 'documentation', component: HomeComponent }, // TODO: we need to Create DocumentationComponent
  { path: '**', redirectTo: '' }
];
