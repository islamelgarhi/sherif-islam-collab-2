import React from 'react';
import { FileText, Download } from 'lucide-react';
import { Button } from '../ui/Button';

export function BillingHistory() {
  const invoices = [
    { id: 1, date: 'Mar 1, 2024', amount: '$19.99', status: 'Paid', invoice: '#INV-2024-001' },
    { id: 2, date: 'Feb 1, 2024', amount: '$19.99', status: 'Paid', invoice: '#INV-2024-002' },
    { id: 3, date: 'Jan 1, 2024', amount: '$19.99', status: 'Paid', invoice: '#INV-2024-003' }
  ];

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <div>
          <h3 className="text-lg font-semibold text-white mb-1">Billing History</h3>
          <p className="text-sm text-gray-400">View and download past invoices</p>
        </div>
      </div>

      <div className="space-y-3">
        {invoices.map((invoice) => (
          <div 
            key={invoice.id}
            className="flex items-center justify-between p-4 bg-white/5 rounded-lg border border-white/10"
          >
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-lg bg-primary/10 flex items-center justify-center">
                <FileText className="w-5 h-5 text-primary" />
              </div>
              <div>
                <h4 className="text-white font-medium">{invoice.invoice}</h4>
                <p className="text-sm text-gray-400">{invoice.date}</p>
              </div>
            </div>
            <div className="flex items-center gap-4">
              <div>
                <p className="text-white text-right">{invoice.amount}</p>
                <p className="text-sm text-green-400">{invoice.status}</p>
              </div>
              <Button variant="secondary" size="sm">
                <Download className="w-4 h-4" />
              </Button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}