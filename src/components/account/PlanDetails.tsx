import React, { useState } from 'react';
import { Package, CheckCircle } from 'lucide-react';
import { Button } from '../ui/Button';
import { PlanSelectionModal } from './PlanSelectionModal';

export function PlanDetails() {
  const [isModalOpen, setIsModalOpen] = useState(false);

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <div>
          <h3 className="text-lg font-semibold text-white mb-1">Current Plan</h3>
          <p className="text-sm text-gray-400">Manage your subscription and billing</p>
        </div>
        <div className="px-3 py-1 rounded-full bg-primary/10 text-primary text-sm">
          Professional Plan
        </div>
      </div>

      <div className="bg-white/5 rounded-lg border border-white/10 p-4">
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-3">
            <Package className="w-5 h-5 text-primary" />
            <div>
              <h4 className="text-white font-medium">Professional</h4>
              <p className="text-sm text-gray-400">$19.99/month</p>
            </div>
          </div>
          <Button 
            variant="secondary"
            onClick={() => setIsModalOpen(true)}
          >
            Change Plan
          </Button>
        </div>

        <div className="space-y-2">
          <div className="flex items-center gap-2 text-gray-300">
            <CheckCircle className="w-4 h-4 text-primary" />
            <span>Up to 500 review monitoring</span>
          </div>
          <div className="flex items-center gap-2 text-gray-300">
            <CheckCircle className="w-4 h-4 text-primary" />
            <span>AI-powered response suggestions</span>
          </div>
          <div className="flex items-center gap-2 text-gray-300">
            <CheckCircle className="w-4 h-4 text-primary" />
            <span>Multi-platform integration</span>
          </div>
        </div>
      </div>

      <PlanSelectionModal 
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        currentPlan="professional"
      />
    </div>
  );
}