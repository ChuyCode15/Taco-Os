import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatCardModule } from '@angular/material/card';
import { MatIconModule } from '@angular/material/icon';
import { ApiService } from '../../core/api.service';

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [CommonModule, MatCardModule, MatIconModule],
  template: `
    <h2 class="text-xl font-bold mb-6">Dashboard</h2>
    @if (stats) {
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
        <mat-card class="p-4">
          <div class="flex items-center gap-3">
            <mat-icon class="text-blue-500">people</mat-icon>
            <div>
              <p class="text-2xl font-bold">{{stats.totalClientesActivos}}</p>
              <p class="text-sm text-gray-500">Clientes Activos</p>
            </div>
          </div>
        </mat-card>
        <mat-card class="p-4">
          <div class="flex items-center gap-3">
            <mat-icon class="text-green-500">payments</mat-icon>
            <div>
              <p class="text-2xl font-bold">\${{stats.ingresosMensuales}}</p>
              <p class="text-sm text-gray-500">Ingresos Mensuales</p>
            </div>
          </div>
        </mat-card>
        <mat-card class="p-4">
          <div class="flex items-center gap-3">
            <mat-icon class="text-orange-500">support_agent</mat-icon>
            <div>
              <p class="text-2xl font-bold">{{stats.ticketsAbiertos}}</p>
              <p class="text-sm text-gray-500">Tickets Abiertos</p>
            </div>
          </div>
        </mat-card>
        <mat-card class="p-4">
          <div class="flex items-center gap-3">
            <mat-icon class="text-red-500">warning</mat-icon>
            <div>
              <p class="text-2xl font-bold">{{stats.incidenciasAbiertas}}</p>
              <p class="text-sm text-gray-500">Incidencias</p>
            </div>
          </div>
        </mat-card>
      </div>

      <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <mat-card class="p-4">
          <h3 class="font-semibold mb-3">Tickets por Estado</h3>
          <div class="space-y-2">
            <div class="flex justify-between"><span>Abiertos</span><span class="font-bold text-orange-500">{{stats.ticketsAbiertos}}</span></div>
            <div class="flex justify-between"><span>Resueltos</span><span class="font-bold text-green-500">{{stats.ticketsResueltos}}</span></div>
          </div>
        </mat-card>
        <mat-card class="p-4">
          <h3 class="font-semibold mb-3">Actividad Reciente</h3>
          <div class="space-y-2 max-h-64 overflow-y-auto">
            @for (item of stats.actividadReciente; track item.id) {
              <div class="flex items-center gap-2 text-sm border-b pb-2">
                <mat-icon class="text-xs text-gray-400">history</mat-icon>
                <span>{{item.accion}} - {{item.tipoObjetivo}}</span>
                <span class="ml-auto text-gray-400 text-xs">{{item.creadoEl | date:'short'}}</span>
              </div>
            }
          </div>
        </mat-card>
      </div>
    } @else {
      <p>Cargando estadísticas...</p>
    }
  `,
})
export class DashboardComponent implements OnInit {
  stats: any = null;

  constructor(private api: ApiService) {}

  ngOnInit() {
    this.api.getDashboardStats().subscribe(data => this.stats = data);
  }
}
