import React from 'react';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faArrowRight, faCheck } from '@fortawesome/free-solid-svg-icons';

const steps = [
  {
    step: 1,
    title: 'Buyer Initiates Order',
    description: "Commodity buyers access their dashboard and initiate a new order by entering the seller's email.",
    label: 'Buyer Dashboard',
    icon: faArrowRight,
  },
  {
    step: 2,
    title: 'Seller Receives Link',
    description: 'The seller receives an email with a secure link to submit their business details and invoice.',
    label: 'Secure Form',
    icon: faArrowRight,
  },
  {
    step: 3,
    title: 'Invoice Verification',
    description: 'Our protocol verifies the invoice details and prepares funding based on the commodity value.',
    label: 'Smart Contracts',
    icon: faArrowRight,
  },
  {
    step: 4,
    title: 'Delivery Confirmation',
    description: 'The buyer confirms receipt of commodities, triggering the final settlement between all parties.',
    label: 'Proof of Delivery',
    icon: faCheck,
  },
];

const HowItWorks = () => {
  return (
    <section className="container mx-auto px-6 py-20">
      <div className="text-center mb-16">
        <span className="text-qaccent font-mono mb-2 block">PROCESS</span>
        <h2 className="text-4xl font-bold mb-4">How Q Wallet Works</h2>
        <p className="text-xl text-gray-400 max-w-2xl mx-auto">
          A seamless four-step process that transforms commodity invoices into working capital.
        </p>
      </div>

      <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-8">
        {steps.map((step) => (
          <div key={step.step} className="step-card gradient-border p-1 rounded-xl bg-qgray">
            <div className="bg-qblack rounded-xl p-8 h-full">
              <div className="w-14 h-14 rounded-full bg-qgray flex items-center justify-center mb-6 glow">
                <span className="text-qaccent font-bold text-xl">{step.step}</span>
              </div>
              <h3 className="text-xl font-bold mb-3">{step.title}</h3>
              <p className="text-gray-400 mb-6">{step.description}</p>
              <div className="flex items-center space-x-2 text-sm text-qaccent">
                <span>{step.label}</span>
                <FontAwesomeIcon icon={step.icon} />
              </div>
            </div>
          </div>
        ))}
      </div>
    </section>
  );
};

export default HowItWorks;
