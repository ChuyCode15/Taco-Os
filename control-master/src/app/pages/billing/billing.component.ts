import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatTableModule } from '@angular/material/table';
import { MatCardModule } from '@angular/material/card';
import { ApiService } from '../../core/api.service';

@Component({
  selector: 'app-billing',
  standalone: true,
  imports: [CommonModule, MatTableModule, MatCardModule],
  template: `
    <h2 class="text-xl font-bold mb-6">Facturación</h2>
    @if (summary) {
      <div class="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
        <mat-card class="p-4 text-center">
          <p class="text-2xl font-bold text-green-600">\${{summary.pagadosMes}}</p>
          <p class="text-sm text-gray-500">Pagados</p>
        </mat-card>
        <mat-card class="p-4 text-center">
          <p class="text-2xl font-bold text-orange-500">\${{summary.pendientesMes}}</p>
          <p class="text-sm text-gray-500">Pendientes</p>
        </mat-card>
        <mat-card class="p-4 text-center">
          <p class="text-2xl font-bold text-blue-600">\${{summary.mrr}}</p>
          <p class="text-sm text-gray-500">MRR</p>
        </mat-card>
        <mat-card class="p-4 text-center">
          <p class="text-2xl font-bold text-gray-800">\${{summary.ingresosMensuales}}</p>
          <p class="text-sm text-gray-500">Total Mensual</p>
        </mat-card>
      </div>
    }
    <div class="bg-white rounded-lg shadow overflow-hidden">
      <table mat-table [dataSource]="invoices" class="w-full">
        <ng-container matColumnDef="cliente">
          <th mat-header-cell *matHeaderCellDef>Cliente</th>
          <td mat-cell *matCellDef="let i">{{i.clienteNombre}}</td>
        </ng-container>
        <ng-container matColumnDef="monto">
          <th mat-header-cell *matHeaderCellDef>Monto</th>
          <td mat-cell *matCellDef="let i">\${{i.monto}}</td>
        </ng-container>
        <ng-container matColumnDef="plan">
          <th mat-header-cell *matHeaderCellDef>Plan</th>
          <td mat-cell *matCellDef="let i">{{i.plan}}</td>
        </ng-container>
        <ng-container matColumnDef="estado">
          <th mat-header-cell *matHeaderCellDef>Estado</th>
          <td mat-cell *matCellDef="let i">
            <span [class]="i.estado === 'PAGADA' ? 'text-green-600' : 'text-orange-500'">{{i.estado}}</span>
          </td>
        </ng-container>
        <ng-container matColumnDef="vence">
          <th mat-header-cell *matHeaderCellDef>Vence</th>
          <td mat-cell *matCellDef="let i">{{i.fechaVencimiento}}</td>
        </ng-container>
        <tr mat-header-row *matHeaderRowDef="columns"></tr>
        <tr mat-row *matRowDef="let row; columns: columns;"></tr>
      </table>
    </div>
  `,
})
export class BillingComponent implements OnInit {
  summary: any = null;
  invoices: any[] = [];
  columns = ['cliente', 'monto', 'plan', 'estado', 'vence'];

  constructor(private api: ApiService) {}

  ngOnInit() {
    this.api.getBillingSummary().subscribe(data => this.summary = data);
    this.api.getInvoices().subscribe(data => this.invoices = data);
  }
}
