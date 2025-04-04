import React from 'react';

const Navbar = () => {
  return (
    <nav className="container mx-auto px-6 py-6 flex justify-between items-center">
      <div className="flex items-center space-x-2">
        <div className="w-8 h-8 rounded-full bg-gradient-to-r from-qprimary to-qaccent"></div>
        <span className="text-2xl font-bold">Q WALLET</span>
      </div>
      <div className="hidden md:flex items-center space-x-8">
        <a href="#" className="nav-link">Product</a>
        <a href="#" className="nav-link">Solutions</a>
        <a href="#" className="nav-link">Pricing</a>
        <a href="#" className="nav-link">Resources</a>
      </div>
      <div className="flex items-center space-x-4">
        <button className="px-4 py-2 rounded-lg border border-qgray hover:bg-qgray transition">Sign In</button>
        <button className="px-4 py-2 rounded-lg bg-gradient-to-r from-qprimary to-qaccent text-qblack font-medium hover:opacity-90 transition">Get Started</button>
      </div>
    </nav>
  );
};

export default Navbar;
