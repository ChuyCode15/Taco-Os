import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { MatCardModule } from '@angular/material/card';
import { MatInputModule } from '@angular/material/input';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { AuthService } from '../../core/auth.service';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [CommonModule, FormsModule, MatCardModule, MatInputModule, MatButtonModule, MatIconModule],
  template: `
    <div class="min-h-screen flex items-center justify-center bg-gradient-to-br from-gray-900 via-blue-900 to-gray-900">
      <mat-card class="w-full max-w-md p-8">
        <div class="text-center mb-8">
          <h1 class="text-2xl font-bold text-gray-800">Taco'Os</h1>
          <p class="text-gray-500 mt-1">Control Maestro</p>
        </div>
        <form (ngSubmit)="onLogin()">
          <mat-form-field class="w-full" appearance="outline">
            <mat-label>Usuario</mat-label>
            <input matInput [(ngModel)]="username" name="username" required>
            <mat-icon matPrefix>person</mat-icon>
          </mat-form-field>
          <mat-form-field class="w-full" appearance="outline">
            <mat-label>Contraseña</mat-label>
            <input matInput [(ngModel)]="password" name="password" [type]="hidePassword ? 'password' : 'text'" required>
            <mat-icon matPrefix>lock</mat-icon>
            <button mat-icon-button matSuffix type="button" (click)="hidePassword = !hidePassword">
              <mat-icon>{{hidePassword ? 'visibility_off' : 'visibility'}}</mat-icon>
            </button>
          </mat-form-field>
          @if (error) {
            <p class="text-red-500 text-sm mb-4">{{error}}</p>
          }
          <button mat-flat-button color="primary" class="w-full" type="submit" [disabled]="loading">
            {{loading ? 'Ingresando...' : 'Ingresar'}}
          </button>
        </form>
      </mat-card>
    </div>
  `,
})
export class LoginComponent {
  username = '';
  password = '';
  hidePassword = true;
  loading = false;
  error = '';

  constructor(private auth: AuthService, private router: Router) {}

  onLogin() {
    this.loading = true;
    this.error = '';
    this.auth.login(this.username, this.password).subscribe({
      next: () => {
        this.router.navigate(['/dashboard']);
      },
      error: (err) => {
        this.loading = false;
        this.error = err.error?.mensaje || 'Error de autenticación';
      },
    });
  }
}
