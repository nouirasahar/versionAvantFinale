import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';


@Component({
  selector: 'app-home',
  standalone: true,
  imports: [CommonModule, RouterLink],
  templateUrl: './home.component.html',
  styleUrls: ['./home.component.css']
})
export class HomeComponent {

  frontendFrameworks = [
  { name: 'React', icon: 'react.png' },
  { name: 'Angular', icon: 'angular.png' },
  { name: 'Vue.js', icon: 'vuejs.png' }
  ];

  backendFrameworks = [
  { name: 'Node.js', icon: 'node.png' },
  { name: 'Spring Boot', icon: 'springboot.png' },
  { name: 'Django', icon: 'django.png' }
  ];

  databases = [
    { name: 'PostgreSQL', icon: 'postgresql.png' },
    { name: 'MySQL', icon: 'mysql.png' },
    { name: 'MongoDB', icon: 'mongodb.png' }
  ];

  features = [
    {
      title: '💻 Full Stack Generation',
      description: 'Generate frontend and backend code with a single click',
      icon: 'fas fa-code'
    },
    {
      title: '🗄️ Database Integration',
      description: 'You connect to your own database and get  Automatically created APIs ',
      icon: 'fas fa-database'
    },
    {
      title: '🧩 Multiple Frameworks',
      description: 'Support for various frontend and backend frameworks',
      icon: 'fas fa-layer-group'
    },
    {
      title: '🌐 Shared Environments',
      description: 'Execution will take place in shared environments (Docker, virtual machines, or physical machines)',
      icon: 'fas fa-rocket'
    },
    {
      title: '📊 Admin Dashboard',
      description: 'Easily visualize and manage your database through an automatically generated dynamic interface.',
      icon: 'fas fa-chart-line'
    }
  ];


  steps = [
    {
      number: 1,
      title: '🧩 Choose Your Stack',
      description: 'Select your preferred frontend, backend, and database technologies'
    },
    {
      number: 2,
      title: '🛠️ Configure Database',
      description: 'Enter your database credentials and connection details'
    },
    {
      number: 3,
      title: '🚀 Generate Project',
      description: 'Download your project and start coding right away'
    }

  ];

}
