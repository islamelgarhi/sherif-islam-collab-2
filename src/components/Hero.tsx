import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { VideoModal } from './VideoModal';
import { HeroContent } from './hero/HeroContent';
import { HeroActions } from './hero/HeroActions';
import { HeroDashboard } from './hero/HeroDashboard';
import { GradientBackground } from './effects/GradientBackground';
import Scene from './three/Scene';

export default function Hero() {
  const navigate = useNavigate();
  const [isVideoOpen, setIsVideoOpen] = useState(false);

  const handleFreeTrial = () => {
    navigate('/free-trial');
  };

  const handleWatchDemo = () => {
    setIsVideoOpen(true);
  };

  return (
    <GradientBackground 
      variant="hero" 
      className="min-h-screen flex items-center justify-center overflow-hidden px-4 sm:px-6"
    >
      {/* 3D Scene Background */}
      <Scene />

      <div className="max-w-7xl mx-auto py-24 lg:py-32 relative z-10">
        <HeroContent />
        <HeroActions 
          onFreeTrial={handleFreeTrial} 
          onWatchDemo={handleWatchDemo} 
        />
        <HeroDashboard />
      </div>

      {/* Video Modal */}
      <VideoModal 
        isOpen={isVideoOpen} 
        onClose={() => setIsVideoOpen(false)} 
      />
    </GradientBackground>
  );
}