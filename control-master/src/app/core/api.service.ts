import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

@Injectable({ providedIn: 'root' })
export class ApiService {
  private readonly BASE = 'http://localhost:8080/api/v1/master';

  constructor(private http: HttpClient) {}

  // Dashboard
  getDashboardStats(): Observable<any> {
    return this.http.get(`${this.BASE}/dashboard/stats`);
  }

  // Clients
  getClients(): Observable<any[]> {
    return this.http.get<any[]>(`${this.BASE}/clients`);
  }

  getClientDetail(id: string): Observable<any> {
    return this.http.get(`${this.BASE}/clients/${id}`);
  }

  toggleClient(id: string): Observable<void> {
    return this.http.put<void>(`${this.BASE}/clients/${id}/toggle`, {});
  }

  // Tickets
  getTickets(): Observable<any[]> {
    return this.http.get<any[]>(`${this.BASE}/tickets`);
  }

  getTicketDetail(id: string): Observable<any> {
    return this.http.get(`${this.BASE}/tickets/${id}`);
  }

  createTicket(data: any): Observable<any> {
    return this.http.post(`${this.BASE}/tickets`, data);
  }

  assignTicket(id: string, data: any): Observable<void> {
    return this.http.put<void>(`${this.BASE}/tickets/${id}/assign`, data);
  }

  updateTicketStatus(id: string, status: string): Observable<void> {
    return this.http.put<void>(`${this.BASE}/tickets/${id}/status?status=${status}`, {});
  }

  getTicketMessages(id: string): Observable<any[]> {
    return this.http.get<any[]>(`${this.BASE}/tickets/${id}/messages`);
  }

  sendMessage(ticketId: string, data: any): Observable<any> {
    return this.http.post(`${this.BASE}/tickets/${ticketId}/messages`, data);
  }

  // Operations
  forceCloseSession(data: any): Observable<void> {
    return this.http.post<void>(`${this.BASE}/ops/force-close-session`, data);
  }

  adjustBalance(data: any): Observable<void> {
    return this.http.put<void>(`${this.BASE}/ops/adjust-balance`, data);
  }

  blockUser(data: any): Observable<void> {
    return this.http.put<void>(`${this.BASE}/ops/block-user`, data);
  }

  // Team
  getTeam(): Observable<any[]> {
    return this.http.get<any[]>(`${this.BASE}/team`);
  }

  getTeamMember(id: string): Observable<any> {
    return this.http.get(`${this.BASE}/team/${id}`);
  }

  createTeamMember(data: any): Observable<any> {
    return this.http.post(`${this.BASE}/team`, data);
  }

  toggleTeamMember(id: string): Observable<void> {
    return this.http.put<void>(`${this.BASE}/team/${id}/toggle`, {});
  }

  // Billing
  getBillingSummary(): Observable<any> {
    return this.http.get(`${this.BASE}/billing/summary`);
  }

  getInvoices(): Observable<any[]> {
    return this.http.get<any[]>(`${this.BASE}/billing/invoices`);
  }
}
