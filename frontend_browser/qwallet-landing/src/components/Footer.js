import React from 'react';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faTwitter, faLinkedinIn, faTelegramPlane } from '@fortawesome/free-brands-svg-icons';

const Footer = () => {
  return (
    <footer className="border-t border-qgray">
      <div className="container mx-auto px-6 py-12">
        <div className="grid grid-cols-2 md:grid-cols-5 gap-8">
          <div className="col-span-2">
            <div className="flex items-center space-x-2 mb-4">
              <div className="w-8 h-8 rounded-full bg-gradient-to-r from-qprimary to-qaccent"></div>
              <span className="text-2xl font-bold">Q WALLET</span>
            </div>
            <p className="text-gray-400 mb-6">
              The commodity finance protocol for institutional traders and suppliers.
            </p>
            <div className="flex space-x-4">
              <a href="#" className="w-10 h-10 rounded-full bg-qgray flex items-center justify-center hover:bg-qaccent hover:text-qblack transition">
                <FontAwesomeIcon icon={faTwitter} />
              </a>
              <a href="#" className="w-10 h-10 rounded-full bg-qgray flex items-center justify-center hover:bg-qaccent hover:text-qblack transition">
                <FontAwesomeIcon icon={faLinkedinIn} />
              </a>
              <a href="#" className="w-10 h-10 rounded-full bg-qgray flex items-center justify-center hover:bg-qaccent hover:text-qblack transition">
                <FontAwesomeIcon icon={faTelegramPlane} />
              </a>
            </div>
          </div>

          <div>
            <h3 className="text-lg font-bold mb-4">Product</h3>
            <ul className="space-y-2">
              <li><a href="#" className="text-gray-400 hover:text-qaccent transition">Features</a></li>
              <li><a href="#" className="text-gray-400 hover:text-qaccent transition">Pricing</a></li>
              <li><a href="#" className="text-gray-400 hover:text-qaccent transition">API</a></li>
              <li><a href="#" className="text-gray-400 hover:text-qaccent transition">Integrations</a></li>
            </ul>
          </div>

          <div>
            <h3 className="text-lg font-bold mb-4">Resources</h3>
            <ul className="space-y-2">
              <li><a href="#" className="text-gray-400 hover:text-qaccent transition">Documentation</a></li>
              <li><a href="#" className="text-gray-400 hover:text-qaccent transition">Guides</a></li>
              <li><a href="#" className="text-gray-400 hover:text-qaccent transition">Blog</a></li>
              <li><a href="#" className="text-gray-400 hover:text-qaccent transition">Support</a></li>
            </ul>
          </div>

          <div>
            <h3 className="text-lg font-bold mb-4">Company</h3>
            <ul className="space-y-2">
              <li><a href="#" className="text-gray-400 hover:text-qaccent transition">About</a></li>
              <li><a href="#" className="text-gray-400 hover:text-qaccent transition">Careers</a></li>
              <li><a href="#" className="text-gray-400 hover:text-qaccent transition">Legal</a></li>
              <li><a href="#" className="text-gray-400 hover:text-qaccent transition">Contact</a></li>
            </ul>
          </div>
        </div>

        <div className="border-t border-qgray mt-12 pt-8 flex flex-col md:flex-row justify-between items-center">
          <p className="text-gray-400 mb-4 md:mb-0">© 2023 Q Wallet Protocol. All rights reserved.</p>
          <div className="flex space-x-6">
            <a href="#" className="text-gray-400 hover:text-qaccent transition">Privacy Policy</a>
            <a href="#" className="text-gray-400 hover:text-qaccent transition">Terms of Service</a>
          </div>
        </div>
      </div>
    </footer>
  );
};

export default Footer;
