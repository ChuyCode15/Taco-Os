import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { MatCardModule } from '@angular/material/card';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatInputModule } from '@angular/material/input';
import { ApiService } from '../../core/api.service';

@Component({
  selector: 'app-ticket-detail',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterLink, MatCardModule, MatButtonModule, MatIconModule, MatInputModule],
  template: `
    @if (ticket) {
      <div class="flex items-center gap-4 mb-6">
        <a mat-icon-button routerLink="/tickets"><mat-icon>arrow_back</mat-icon></a>
        <h2 class="text-xl font-bold">{{ticket.titulo}}</h2>
        <span [class]="getStatusClass(ticket.estado)">{{ticket.estado}}</span>
      </div>
      <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div class="lg:col-span-2">
          <mat-card class="p-4">
            <h3 class="font-semibold mb-3">Mensajes</h3>
            <div class="space-y-3 max-h-96 overflow-y-auto mb-4">
              @for (msg of messages; track msg.id) {
                <div [class]="msg.tipoEmisor === 'STAFF' ? 'ml-8' : 'mr-8'">
                  <div [class]="msg.tipoEmisor === 'STAFF' ? 'bg-blue-50 border-l-4 border-blue-400' : 'bg-gray-50 border-l-4 border-gray-400'" class="p-3 rounded">
                    <p class="text-xs text-gray-500 mb-1">{{msg.emisorNombre}} - {{msg.creadoEl | date:'short'}}</p>
                    <p class="text-sm">{{msg.contenido}}</p>
                  </div>
                </div>
              }
            </div>
            <div class="flex gap-2">
              <mat-form-field class="flex-1" appearance="outline">
                <input matInput [(ngModel)]="newMessage" placeholder="Escribe un mensaje..." (keyup.enter)="sendMessage()">
              </mat-form-field>
              <button mat-flat-button color="primary" (click)="sendMessage()" [disabled]="!newMessage">Enviar</button>
            </div>
          </mat-card>
        </div>
        <div>
          <mat-card class="p-4 mb-4">
            <h3 class="font-semibold mb-3">Detalles</h3>
            <div class="space-y-2 text-sm">
              <div class="flex justify-between"><span class="text-gray-500">Cliente:</span><span>{{ticket.clienteNombre}}</span></div>
              <div class="flex justify-between"><span class="text-gray-500">Prioridad:</span><span>{{ticket.prioridad}}</span></div>
              <div class="flex justify-between"><span class="text-gray-500">Asignado:</span><span>{{ticket.asignadoA || 'Sin asignar'}}</span></div>
              <div class="flex justify-between"><span class="text-gray-500">Creado:</span><span>{{ticket.creadoEl | date:'medium'}}</span></div>
            </div>
          </mat-card>
          <mat-card class="p-4">
            <h3 class="font-semibold mb-3">Acciones</h3>
            <div class="space-y-2">
              @if (ticket.estado === 'ABIERTO') {
                <button mat-flat-button color="primary" class="w-full" (click)="updateStatus('EN_PROGRESO')">Iniciar Progreso</button>
              }
              @if (ticket.estado === 'EN_PROGRESO') {
                <button mat-flat-button color="accent" class="w-full" (click)="updateStatus('RESUELTO')">Marcar Resuelto</button>
              }
              @if (ticket.estado !== 'CERRADO') {
                <button mat-stroked-button color="warn" class="w-full" (click)="updateStatus('CERRADO')">Cerrar Ticket</button>
              }
            </div>
          </mat-card>
        </div>
      </div>
    }
  `,
})
export class TicketDetailComponent implements OnInit {
  ticket: any = null;
  messages: any[] = [];
  newMessage = '';

  constructor(private route: ActivatedRoute, private api: ApiService) {}

  ngOnInit() {
    const id = this.route.snapshot.paramMap.get('id')!;
    this.api.getTicketDetail(id).subscribe(data => this.ticket = data);
    this.api.getTicketMessages(id).subscribe(data => this.messages = data);
  }

  sendMessage() {
    if (!this.newMessage.trim()) return;
    const id = this.route.snapshot.paramMap.get('id')!;
    this.api.sendMessage(id, { contenido: this.newMessage }).subscribe(msg => {
      this.messages.push(msg);
      this.newMessage = '';
    });
  }

  updateStatus(status: string) {
    const id = this.route.snapshot.paramMap.get('id')!;
    this.api.updateTicketStatus(id, status).subscribe(() => {
      this.ticket.estado = status;
    });
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
