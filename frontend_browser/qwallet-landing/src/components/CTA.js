import React from 'react';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faGoogle, faHeadset } from '@fortawesome/free-solid-svg-icons';

const CTA = () => {
  return (
    <section className="container mx-auto px-6 py-32">
      <div className="gradient-border p-1 rounded-2xl">
        <div className="bg-qgray rounded-2xl p-12 text-center">
          <h2 className="text-4xl font-bold mb-6">Ready to Transform Your Commodity Financing?</h2>
          <p className="text-xl text-gray-400 max-w-2xl mx-auto mb-8">
            Join the protocol that's redefining how commodity traders access working capital.
          </p>
          <div className="flex flex-col sm:flex-row justify-center space-y-4 sm:space-y-0 sm:space-x-4">
            <button className="google-btn px-8 py-4 rounded-lg bg-gradient-to-r from-qprimary to-qaccent text-qblack font-bold flex items-center justify-center">
              <FontAwesomeIcon icon={faGoogle} className="mr-3" />
              Sign Up with Google
            </button>
            <button className="px-8 py-4 rounded-lg border border-qgray hover:bg-qblack transition flex items-center justify-center">
              <FontAwesomeIcon icon={faHeadset} className="mr-3" />
              Schedule a Demo
            </button>
          </div>
        </div>
      </div>
    </section>
  );
};

export default CTA;
