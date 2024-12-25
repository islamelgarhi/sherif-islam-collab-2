import React from 'react';
import { Link, useLocation } from 'react-router-dom';
import { cn } from '@/utils/cn';

interface NavLinkProps {
  to: string;
  children: React.ReactNode;
  className?: string;
}

export function NavLink({ to, children, className }: NavLinkProps) {
  const location = useLocation();
  const isActive = location.pathname === to;

  return (
    <Link 
      to={to} 
      className={cn(
        "relative text-sm font-medium transition-colors duration-200",
        "hover:text-primary",
        // Active state styles
        isActive ? [
          "text-primary",
          "after:absolute after:bottom-0 after:left-0 after:right-0",
          "after:h-0.5 after:bg-primary",
          "after:animate-[expand_0.2s_ease-out_forwards]"
        ] : "text-gray-400",
        className
      )}
      aria-current={isActive ? 'page' : undefined}
    >
      {children}
    </Link>
  );
}