import React from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { LogIn } from 'lucide-react';
import { Button } from '../ui/Button';
import { useAuth } from '@/contexts/AuthContext';
import { ProfileMenu } from './ProfileMenu';
import { cn } from '@/utils/cn';

interface NavActionsProps {
  className?: string;
}

export function NavActions({ className }: NavActionsProps) {
  const { user } = useAuth();
  const navigate = useNavigate();

  const handleFreeTrial = () => {
    navigate('/free-trial');
  };

  return (
    <div className={cn("flex items-center gap-4", className)}>
      {user ? (
        <ProfileMenu />
      ) : (
        <>
          <Button 
            as={Link}
            to="/login"
            variant="secondary"
            className={cn(
              "min-w-[120px]",
              "inline-flex items-center justify-center",
              "hover:bg-white/20",
              "transition-all duration-300"
            )}
          >
            <LogIn className="w-4 h-4 mr-2" />
            Login
          </Button>
          
          <Button
            onClick={handleFreeTrial}
            className={cn(
              "min-w-[120px]",
              "inline-flex items-center justify-center",
              "hover:scale-105",
              "transition-all duration-300"
            )}
          >
            Start Free Trial
          </Button>
        </>
      )}
    </div>
  );
}