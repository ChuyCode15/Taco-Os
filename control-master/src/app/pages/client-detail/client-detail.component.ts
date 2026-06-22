import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { MatCardModule } from '@angular/material/card';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { ApiService } from '../../core/api.service';

@Component({
  selector: 'app-client-detail',
  standalone: true,
  imports: [CommonModule, RouterLink, MatCardModule, MatButtonModule, MatIconModule],
  template: `
    @if (client) {
      <div class="flex items-center gap-4 mb-6">
        <a mat-icon-button routerLink="/clients"><mat-icon>arrow_back</mat-icon></a>
        <h2 class="text-xl font-bold">{{client.nombreCompleto}}</h2>
        <span [class]="client.activo ? 'text-green-600' : 'text-red-600'">{{client.activo ? 'Activo' : 'Inactivo'}}</span>
      </div>
      <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <mat-card class="p-4">
          <h3 class="font-semibold mb-3">Información Personal</h3>
          <div class="space-y-2 text-sm">
            <div class="flex justify-between"><span class="text-gray-500">Nickname:</span><span>{{client.nickname}}</span></div>
            <div class="flex justify-between"><span class="text-gray-500">Email:</span><span>{{client.correo}}</span></div>
            <div class="flex justify-between"><span class="text-gray-500">Teléfono:</span><span>{{client.numero || '-'}}</span></div>
            <div class="flex justify-between"><span class="text-gray-500">Registro:</span><span>{{client.registro | date:'medium'}}</span></div>
          </div>
        </mat-card>
        <mat-card class="p-4">
          <h3 class="font-semibold mb-3">Negocio</h3>
          <div class="space-y-2 text-sm">
            <div class="flex justify-between"><span class="text-gray-500">Nombre:</span><span>{{client.negocioNombre || '-'}}</span></div>
            <div class="flex justify-between"><span class="text-gray-500">Dirección:</span><span>{{client.negocioDireccion || '-'}}</span></div>
            <div class="flex justify-between"><span class="text-gray-500">Cajeros:</span><span>{{client.totalCajeros}}</span></div>
          </div>
        </mat-card>
        <mat-card class="p-4">
          <h3 class="font-semibold mb-3">Plan</h3>
          <div class="space-y-2 text-sm">
            <div class="flex justify-between"><span class="text-gray-500">Tipo:</span><span class="font-bold">{{client.plan}}</span></div>
            <div class="flex justify-between"><span class="text-gray-500">Estado:</span><span>{{client.estadoPlan || '-'}}</span></div>
            <div class="flex justify-between"><span class="text-gray-500">Vence:</span><span>{{client.fechaVencimiento || '-'}}</span></div>
          </div>
        </mat-card>
        <mat-card class="p-4">
          <h3 class="font-semibold mb-3">Soporte</h3>
          <div class="space-y-2 text-sm">
            <div class="flex justify-between"><span class="text-gray-500">Tickets abiertos:</span><span class="font-bold">{{client.ticketsAbiertos}}</span></div>
          </div>
          <div class="mt-4 flex gap-2">
            <button mat-flat-button color="warn" (click)="toggleClient()">
              {{client.activo ? 'Desactivar' : 'Activar'}}
            </button>
          </div>
        </mat-card>
      </div>
    }
  `,
})
export class ClientDetailComponent implements OnInit {
  client: any = null;

  constructor(private route: ActivatedRoute, private api: ApiService) {}

  ngOnInit() {
    const id = this.route.snapshot.paramMap.get('id')!;
    this.api.getClientDetail(id).subscribe(data => this.client = data);
  }

  toggleClient() {
    this.api.toggleClient(this.client.id).subscribe(() => {
      this.client.activo = !this.client.activo;
    });
  }
}
