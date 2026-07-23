import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { MatCardModule } from '@angular/material/card';
import { MatButtonModule } from '@angular/material/button';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { MatIconModule } from '@angular/material/icon';
import { ApiService } from '../../core/api.service';

@Component({
  selector: 'app-operations',
  standalone: true,
  imports: [CommonModule, FormsModule, MatCardModule, MatButtonModule, MatInputModule, MatSelectModule, MatIconModule],
  template: `
    <h2 class="text-xl font-bold mb-6">Operaciones</h2>
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      <mat-card class="p-4">
        <div class="flex items-center gap-2 mb-4">
          <mat-icon class="text-red-500">lock</mat-icon>
          <h3 class="font-semibold">Forzar Cierre de Sesión</h3>
        </div>
        <mat-form-field class="w-full" appearance="outline">
          <mat-label>ID Cajero</mat-label>
          <input matInput [(ngModel)]="forceClose.cajeroId">
        </mat-form-field>
        <mat-form-field class="w-full" appearance="outline">
          <mat-label>Razón</mat-label>
          <input matInput [(ngModel)]="forceClose.razon">
        </mat-form-field>
        <button mat-flat-button color="warn" class="w-full" (click)="onForceClose()">Ejecutar</button>
      </mat-card>

      <mat-card class="p-4">
        <div class="flex items-center gap-2 mb-4">
          <mat-icon class="text-blue-500">account_balance</mat-icon>
          <h3 class="font-semibold">Ajustar Saldo</h3>
        </div>
        <mat-form-field class="w-full" appearance="outline">
          <mat-label>ID Negocio</mat-label>
          <input matInput [(ngModel)]="adjustBalance.negocioId">
        </mat-form-field>
        <mat-form-field class="w-full" appearance="outline">
          <mat-label>Nuevo saldo</mat-label>
          <input matInput type="number" [(ngModel)]="adjustBalance.nuevoDineroBase">
        </mat-form-field>
        <mat-form-field class="w-full" appearance="outline">
          <mat-label>Razón</mat-label>
          <input matInput [(ngModel)]="adjustBalance.razon">
        </mat-form-field>
        <button mat-flat-button color="primary" class="w-full" (click)="onAdjustBalance()">Ajustar</button>
      </mat-card>

      <mat-card class="p-4">
        <div class="flex items-center gap-2 mb-4">
          <mat-icon class="text-orange-500">block</mat-icon>
          <h3 class="font-semibold">Bloquear/Desbloquear</h3>
        </div>
        <mat-form-field class="w-full" appearance="outline">
          <mat-label>ID Cliente</mat-label>
          <input matInput [(ngModel)]="blockUser.clienteId">
        </mat-form-field>
        <mat-form-field class="w-full" appearance="outline">
          <mat-label>Acción</mat-label>
          <mat-select [(ngModel)]="blockUser.bloquear">
            <mat-option [value]="true">Bloquear</mat-option>
            <mat-option [value]="false">Desbloquear</mat-option>
          </mat-select>
        </mat-form-field>
        <mat-form-field class="w-full" appearance="outline">
          <mat-label>Razón</mat-label>
          <input matInput [(ngModel)]="blockUser.razon">
        </mat-form-field>
        <button mat-flat-button color="warn" class="w-full" (click)="onBlockUser()">Ejecutar</button>
      </mat-card>
    </div>
    @if (message) {
      <div class="mt-4 p-3 rounded" [class]="messageType === 'success' ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'">
        {{message}}
      </div>
    }
  `,
})
export class OperationsComponent {
  forceClose = { cajeroId: '', razon: '' };
  adjustBalance = { negocioId: '', nuevoDineroBase: 0, razon: '' };
  blockUser = { clienteId: '', bloquear: true, razon: '' };
  message = '';
  messageType = '';

  constructor(private api: ApiService) {}

  onForceClose() {
    this.api.forceCloseSession(this.forceClose).subscribe({
      next: () => this.show('Sesión forzada exitosamente', 'success'),
      error: () => this.show('Error al forzar cierre', 'error'),
    });
  }

  onAdjustBalance() {
    this.api.adjustBalance(this.adjustBalance).subscribe({
      next: () => this.show('Saldo ajustado exitosamente', 'success'),
      error: () => this.show('Error al ajustar saldo', 'error'),
    });
  }

  onBlockUser() {
    this.api.blockUser(this.blockUser).subscribe({
      next: () => this.show('Acción ejecutada exitosamente', 'success'),
      error: () => this.show('Error al ejecutar acción', 'error'),
    });
  }

  show(msg: string, type: string) {
    this.message = msg;
    this.messageType = type;
    setTimeout(() => this.message = '', 3000);
  }
}
