import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { MatTableModule } from '@angular/material/table';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatChipsModule } from '@angular/material/chips';
import { ApiService } from '../../core/api.service';

@Component({
  selector: 'app-clients',
  standalone: true,
  imports: [CommonModule, RouterLink, MatTableModule, MatButtonModule, MatIconModule, MatChipsModule],
  template: `
    <div class="flex justify-between items-center mb-6">
      <h2 class="text-xl font-bold">Clientes</h2>
      <span class="text-sm text-gray-500">{{clients.length}} registros</span>
    </div>
    <div class="bg-white rounded-lg shadow overflow-hidden">
      <table mat-table [dataSource]="clients" class="w-full">
        <ng-container matColumnDef="nombre">
          <th mat-header-cell *matHeaderCellDef>Nombre</th>
          <td mat-cell *matCellDef="let c">{{c.nombreCompleto}}</td>
        </ng-container>
        <ng-container matColumnDef="negocio">
          <th mat-header-cell *matHeaderCellDef>Negocio</th>
          <td mat-cell *matCellDef="let c">{{c.negocioNombre || '-'}}</td>
        </ng-container>
        <ng-container matColumnDef="correo">
          <th mat-header-cell *matHeaderCellDef>Email</th>
          <td mat-cell *matCellDef="let c">{{c.correo}}</td>
        </ng-container>
        <ng-container matColumnDef="plan">
          <th mat-header-cell *matHeaderCellDef>Plan</th>
          <td mat-cell *matCellDef="let c">
            <span [class]="getPlanClass(c.plan)">{{c.plan}}</span>
          </td>
        </ng-container>
        <ng-container matColumnDef="activo">
          <th mat-header-cell *matHeaderCellDef>Estado</th>
          <td mat-cell *matCellDef="let c">
            <span [class]="c.activo ? 'text-green-600' : 'text-red-600'">{{c.activo ? 'Activo' : 'Inactivo'}}</span>
          </td>
        </ng-container>
        <ng-container matColumnDef="acciones">
          <th mat-header-cell *matHeaderCellDef></th>
          <td mat-cell *matCellDef="let c">
            <a mat-icon-button [routerLink]="['/clients', c.id]"><mat-icon>visibility</mat-icon></a>
          </td>
        </ng-container>
        <tr mat-header-row *matHeaderRowDef="columns"></tr>
        <tr mat-row *matRowDef="let row; columns: columns;"></tr>
      </table>
    </div>
  `,
})
export class ClientsComponent implements OnInit {
  clients: any[] = [];
  columns = ['nombre', 'negocio', 'correo', 'plan', 'activo', 'acciones'];

  constructor(private api: ApiService) {}

  ngOnInit() {
    this.api.getClients().subscribe(data => this.clients = data);
  }

  getPlanClass(plan: string): string {
    switch (plan) {
      case 'PREMIUM': return 'bg-purple-100 text-purple-800 px-2 py-1 rounded text-xs font-medium';
      case 'BUSINESS': return 'bg-blue-100 text-blue-800 px-2 py-1 rounded text-xs font-medium';
      default: return 'bg-gray-100 text-gray-800 px-2 py-1 rounded text-xs font-medium';
    }
  }
}
