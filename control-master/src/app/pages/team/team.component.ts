import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatTableModule } from '@angular/material/table';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { ApiService } from '../../core/api.service';

@Component({
  selector: 'app-team',
  standalone: true,
  imports: [CommonModule, MatTableModule, MatButtonModule, MatIconModule],
  template: `
    <div class="flex justify-between items-center mb-6">
      <h2 class="text-xl font-bold">Equipo de Mantenimiento</h2>
      <span class="text-sm text-gray-500">{{members.length}} miembros</span>
    </div>
    <div class="bg-white rounded-lg shadow overflow-hidden">
      <table mat-table [dataSource]="members" class="w-full">
        <ng-container matColumnDef="nombre">
          <th mat-header-cell *matHeaderCellDef>Nombre</th>
          <td mat-cell *matCellDef="let m">{{m.nombreCompleto}}</td>
        </ng-container>
        <ng-container matColumnDef="username">
          <th mat-header-cell *matHeaderCellDef>Usuario</th>
          <td mat-cell *matCellDef="let m">{{m.username}}</td>
        </ng-container>
        <ng-container matColumnDef="rol">
          <th mat-header-cell *matHeaderCellDef>Rol</th>
          <td mat-cell *matCellDef="let m">
            <span [class]="getRolClass(m.rol)">{{m.rol}}</span>
          </td>
        </ng-container>
        <ng-container matColumnDef="tickets">
          <th mat-header-cell *matHeaderCellDef>Tickets</th>
          <td mat-cell *matCellDef="let m">{{m.ticketsAsignados}}</td>
        </ng-container>
        <ng-container matColumnDef="activo">
          <th mat-header-cell *matHeaderCellDef>Estado</th>
          <td mat-cell *matCellDef="let m">
            <span [class]="m.activo ? 'text-green-600' : 'text-red-600'">{{m.activo ? 'Activo' : 'Inactivo'}}</span>
          </td>
        </ng-container>
        <ng-container matColumnDef="acciones">
          <th mat-header-cell *matHeaderCellDef></th>
          <td mat-cell *matCellDef="let m">
            <button mat-icon-button (click)="toggleMember(m)">
              <mat-icon>{{m.activo ? 'person_off' : 'person'}}</mat-icon>
            </button>
          </td>
        </ng-container>
        <tr mat-header-row *matHeaderRowDef="columns"></tr>
        <tr mat-row *matRowDef="let row; columns: columns;"></tr>
      </table>
    </div>
  `,
})
export class TeamComponent implements OnInit {
  members: any[] = [];
  columns = ['nombre', 'username', 'rol', 'tickets', 'activo', 'acciones'];

  constructor(private api: ApiService) {}

  ngOnInit() {
    this.api.getTeam().subscribe(data => this.members = data);
  }

  toggleMember(member: any) {
    this.api.toggleTeamMember(member.id).subscribe(() => {
      member.activo = !member.activo;
    });
  }

  getRolClass(rol: string): string {
    switch (rol) {
      case 'DEVELOPER': return 'bg-purple-100 text-purple-800 px-2 py-1 rounded text-xs font-medium';
      case 'SOPORTE': return 'bg-blue-100 text-blue-800 px-2 py-1 rounded text-xs font-medium';
      case 'DATA_SCIENTIST': return 'bg-green-100 text-green-800 px-2 py-1 rounded text-xs font-medium';
      default: return 'bg-gray-100 text-gray-800 px-2 py-1 rounded text-xs font-medium';
    }
  }
}
