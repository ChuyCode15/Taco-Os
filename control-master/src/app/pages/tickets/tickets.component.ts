import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { MatTableModule } from '@angular/material/table';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { ApiService } from '../../core/api.service';

@Component({
  selector: 'app-tickets',
  standalone: true,
  imports: [CommonModule, RouterLink, MatTableModule, MatButtonModule, MatIconModule],
  template: `
    <div class="flex justify-between items-center mb-6">
      <h2 class="text-xl font-bold">Tickets de Soporte</h2>
      <span class="text-sm text-gray-500">{{tickets.length}} tickets</span>
    </div>
    <div class="bg-white rounded-lg shadow overflow-hidden">
      <table mat-table [dataSource]="tickets" class="w-full">
        <ng-container matColumnDef="id">
          <th mat-header-cell *matHeaderCellDef>#</th>
          <td mat-cell *matCellDef="let t">{{t.id | slice:0:8}}</td>
        </ng-container>
        <ng-container matColumnDef="cliente">
          <th mat-header-cell *matHeaderCellDef>Cliente</th>
          <td mat-cell *matCellDef="let t">{{t.clienteNombre}}</td>
        </ng-container>
        <ng-container matColumnDef="titulo">
          <th mat-header-cell *matHeaderCellDef>Título</th>
          <td mat-cell *matCellDef="let t">{{t.titulo}}</td>
        </ng-container>
        <ng-container matColumnDef="prioridad">
          <th mat-header-cell *matHeaderCellDef>Prioridad</th>
          <td mat-cell *matCellDef="let t">
            <span [class]="getPriorityClass(t.prioridad)">{{t.prioridad}}</span>
          </td>
        </ng-container>
        <ng-container matColumnDef="estado">
          <th mat-header-cell *matHeaderCellDef>Estado</th>
          <td mat-cell *matCellDef="let t">
            <span [class]="getStatusClass(t.estado)">{{t.estado}}</span>
          </td>
        </ng-container>
        <ng-container matColumnDef="asignado">
          <th mat-header-cell *matHeaderCellDef>Asignado a</th>
          <td mat-cell *matCellDef="let t">{{t.asignadoA || '-'}}</td>
        </ng-container>
        <ng-container matColumnDef="acciones">
          <th mat-header-cell *matHeaderCellDef></th>
          <td mat-cell *matCellDef="let t">
            <a mat-icon-button [routerLink]="['/tickets', t.id]"><mat-icon>chat</mat-icon></a>
          </td>
        </ng-container>
        <tr mat-header-row *matHeaderRowDef="columns"></tr>
        <tr mat-row *matRowDef="let row; columns: columns;"></tr>
      </table>
    </div>
  `,
})
export class TicketsComponent implements OnInit {
  tickets: any[] = [];
  columns = ['id', 'cliente', 'titulo', 'prioridad', 'estado', 'asignado', 'acciones'];

  constructor(private api: ApiService) {}

  ngOnInit() {
    this.api.getTickets().subscribe(data => this.tickets = data);
  }

  getPriorityClass(p: string): string {
    switch (p) {
      case 'URGENTE': return 'bg-red-100 text-red-800 px-2 py-1 rounded text-xs font-medium';
      case 'ALTA': return 'bg-orange-100 text-orange-800 px-2 py-1 rounded text-xs font-medium';
      case 'NORMAL': return 'bg-blue-100 text-blue-800 px-2 py-1 rounded text-xs font-medium';
      default: return 'bg-gray-100 text-gray-800 px-2 py-1 rounded text-xs font-medium';
    }
  }

  getStatusClass(s: string): string {
    switch (s) {
      case 'ABIERTO': return 'bg-yellow-100 text-yellow-800 px-2 py-1 rounded text-xs font-medium';
      case 'EN_PROGRESO': return 'bg-blue-100 text-blue-800 px-2 py-1 rounded text-xs font-medium';
      case 'RESUELTO': return 'bg-green-100 text-green-800 px-2 py-1 rounded text-xs font-medium';
      default: return 'bg-gray-100 text-gray-800 px-2 py-1 rounded text-xs font-medium';
    }
  }
}
