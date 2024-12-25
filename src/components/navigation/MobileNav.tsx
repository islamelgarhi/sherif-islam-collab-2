import React from 'react';
import { MobileNavLink } from './MobileNavLink';
import { Button } from '../ui/Button';
import { LogIn } from 'lucide-react';
import { Link } from 'react-router-dom';

interface MobileNavProps {
  onClose: () => void;
}

export function MobileNav({ onClose }: MobileNavProps) {
  return (
    <div className="px-4 pt-2 pb-4 space-y-1">
      <MobileNavLink to="/" onClick={onClose}>Home</MobileNavLink>
      
      {/* Services Section */}
      <div className="px-4 py-2">
        <div className="text-sm font-medium text-gray-400 mb-2">Services</div>
        <div className="pl-4 space-y-1">
          <MobileNavLink to="/short-term-rentals" onClick={onClose}>Rental Properties</MobileNavLink>
          <MobileNavLink to="/restaurant" onClick={onClose}>Restaurants</MobileNavLink>
          <MobileNavLink to="/case-studies" onClick={onClose}>Case Studies</MobileNavLink>
        </div>
      </div>
      
      <MobileNavLink to="/features" onClick={onClose}>Features</MobileNavLink>
      <MobileNavLink to="/pricing" onClick={onClose}>Pricing</MobileNavLink>
      <MobileNavLink to="/blog" onClick={onClose}>Blog</MobileNavLink>
      <MobileNavLink to="/contact" onClick={onClose}>Contact</MobileNavLink>
      
      <div className="pt-4 flex flex-col space-y-2">
        <Button 
          as={Link}
          to="/login"
          variant="secondary"
          icon={<LogIn className="h-5 w-5" />}
          onClick={onClose}
        >
          Login
        </Button>
        
        <Button 
          as={Link}
          to="/free-trial"
          onClick={onClose}
        >
          Start Free Trial
        </Button>
      </div>
    </div>
  );
}