import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '@/contexts/AuthContext';
import { exportUserData, deleteAccount } from '@/services/accountService';

export function useAccountOperations() {
  const [isExporting, setIsExporting] = useState(false);
  const [exportError, setExportError] = useState<string | null>(null);
  const { user, signOut } = useAuth();
  const navigate = useNavigate();

  const handleExportData = async () => {
    if (!user) return;
    
    setIsExporting(true);
    setExportError(null);

    const result = await exportUserData(user.id);
    
    if (!result.success) {
      setExportError(result.error);
    }

    setIsExporting(false);
  };

  const handleDeleteAccount = async () => {
    if (!user) return;

    const result = await deleteAccount(user.id);
    
    if (result.success) {
      await signOut();
      navigate('/');
    } else {
      throw new Error(result.error);
    }
  };

  return {
    handleExportData,
    handleDeleteAccount,
    isExporting,
    exportError
  };
}