import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router, RouterLink } from '@angular/router';
import { ProjectService } from '../../services/project.service';

@Component({
  selector: 'app-tech-choosing',
  standalone: true,
  imports: [CommonModule, RouterLink],
  templateUrl: './tech-choosing.component.html',
  styleUrls: ['./tech-choosing.component.css']
})
export class TechChoosingComponent {
  selectedFrontend: any = null;
  selectedBackend: any = null;
  selectedDatabase: any = null;

  constructor(
    private router: Router,
    private projectService: ProjectService
  ) {}

  frontendOptions = [
    {
      name: 'React',
      description: 'A JavaScript library for building interactive UIs',
      icon: 'react.png',
      id: 'react'
    },
    {
      name: 'Angular',
      description: 'A TypeScript-based framework for building web apps',
      icon: 'angular.png',
      id: 'Angular'
    },
    {
      name: 'Vue.js',
      description: 'A progressive framework for building UIs with ease',
      icon: 'vuejs.png',
      id: 'vue'
    }
  ];

  backendOptions = [
    {
      name: 'Node',
      description: ' a JavaScript runtime built on Chrome`s V8 JavaScript engine.',
      icon: 'node.png',
      id: 'Node'
    },
    {
      name: 'Spring Boot',
      description: 'A Java framework for building production-ready apps',
      icon: 'springboot.png',
      id: 'spring'
    },
    {
      name: 'Django',
      description: 'A Python framework for rapid backend development',
      icon: 'django.png',
      id: 'django'
    }
  ];

  databaseOptions = [
    {
      name: 'PostgreSQL',
      description: 'An advanced open-source relational database',
      icon: 'postgresql.png',
      id: 'postgresql'
    },
    {
      name: 'Mongodb',
      description: 'A flexible NoSQL database using JSON-like documents',
      icon: 'mongodb.png',
      id: 'Mongodb'
    },
    {
      name: 'Mysql',
      description: 'A widely-used open-source relational database',
      icon: 'mysql.png',
      id: 'Mysql'
    }
  ];

  selectFrontend(option: any) {
    this.selectedFrontend = option;
  }

  selectBackend(option: any) {
    this.selectedBackend = option;
  }

  selectDatabase(option: any) {
    this.selectedDatabase = option;
  }

  continueToConfig() {
    if (this.selectedDatabase) {
      // Save the tech stack before navigating
      const techStack = {
        frontend: this.selectedFrontend.name,
        backend: this.selectedBackend.name,
        database: this.selectedDatabase.name
      };
      console.log('Saving tech stack:', techStack);
      this.projectService.setTechStack(techStack);

      this.router.navigate(['/database-configuration']);
    }
  }
}
