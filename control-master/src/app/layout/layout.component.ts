import { Component } from '@angular/core';
import { RouterOutlet, RouterLink, RouterLinkActive } from '@angular/router';
import { MatSidenavModule } from '@angular/material/sidenav';
import { MatToolbarModule } from '@angular/material/toolbar';
import { MatListModule } from '@angular/material/list';
import { MatIconModule } from '@angular/material/icon';
import { MatButtonModule } from '@angular/material/button';
import { AuthService } from '../core/auth.service';

@Component({
  selector: 'app-layout',
  standalone: true,
  imports: [
    RouterOutlet, RouterLink, RouterLinkActive,
    MatSidenavModule, MatToolbarModule, MatListModule,
    MatIconModule, MatButtonModule,
  ],
  template: `
    <mat-sidenav-container class="h-screen">
      <mat-sidenav #sidenav mode="side" opened class="w-64 bg-gray-900 text-white">
        <div class="p-4 text-lg font-bold border-b border-gray-700">Taco'Os Control Maestro</div>
        <mat-nav-list>
          @for (item of navItems; track item.route) {
            <a mat-list-item [routerLink]="item.route" routerLinkActive="bg-gray-700"
               class="text-gray-300 hover:bg-gray-800">
              <mat-icon matListItemIcon>{{item.icon}}</mat-icon>
              <span matListItemTitle>{{item.label}}</span>
            </a>
          }
        </mat-nav-list>
        <div class="absolute bottom-0 w-full p-4 border-t border-gray-700">
          <button mat-button class="w-full text-gray-400" (click)="logout()">
            <mat-icon>logout</mat-icon> Cerrar Sesión
          </button>
        </div>
      </mat-sidenav>
      <mat-sidenav-content>
        <mat-toolbar class="bg-white border-b">
          <span class="flex-1"></span>
          <span class="text-sm text-gray-600">{{auth.getUser()?.nombreCompleto}}</span>
          <span class="ml-2 text-xs bg-blue-100 text-blue-800 px-2 py-1 rounded">{{auth.getUser()?.rol}}</span>
        </mat-toolbar>
        <div class="p-6 bg-gray-50" style="height: calc(100vh - 64px)">
          <router-outlet />
        </div>
      </mat-sidenav-content>
    </mat-sidenav-container>
  `,
})
export class LayoutComponent {
  navItems = [
    { route: '/dashboard', label: 'Dashboard', icon: 'dashboard' },
    { route: '/clients', label: 'Clientes', icon: 'people' },
    { route: '/tickets', label: 'Soporte', icon: 'support_agent' },
    { route: '/operations', label: 'Operaciones', icon: 'build' },
    { route: '/team', label: 'Equipo', icon: 'groups' },
    { route: '/billing', label: 'Facturación', icon: 'payments' },
  ];

  constructor(public auth: AuthService) {}

  logout() {
    this.auth.logout();
  }
}
