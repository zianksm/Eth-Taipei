import React from 'react';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faShieldAlt, faBolt, faChartPie } from '@fortawesome/free-solid-svg-icons';

const features = [
  {
    icon: faShieldAlt,
    title: 'Bank-Grade Security',
    description: 'Multi-signature wallets and institutional custody solutions protect your transactions.',
  },
  {
    icon: faBolt,
    title: 'Instant Settlements',
    description: 'Reduce settlement times from weeks to minutes with our protocol.',
  },
  {
    icon: faChartPie,
    title: 'Real-Time Analytics',
    description: 'Monitor your commodity positions and financing costs in real-time.',
  },
];

const Features = () => {
  return (
    <section className="container mx-auto px-6 py-20">
      <div className="flex flex-col lg:flex-row items-center">
        <div className="lg:w-1/2 mb-12 lg:mb-0 lg:pr-12">
          <span className="text-qaccent font-mono mb-2 block">FEATURES</span>
          <h2 className="text-4xl font-bold mb-6">Built for Commodity Professionals</h2>
          <p className="text-xl text-gray-400 mb-8">
            Q Wallet combines institutional-grade security with an interface designed for high-volume commodity trading.
          </p>

          <div className="space-y-6">
            {features.map((feature, index) => (
              <div key={index} className="flex items-start space-x-4">
                <div className="w-12 h-12 rounded-full bg-qgray flex items-center justify-center flex-shrink-0">
                  <FontAwesomeIcon icon={feature.icon} className="text-qaccent" />
                </div>
                <div>
                  <h3 className="text-xl font-bold mb-2">{feature.title}</h3>
                  <p className="text-gray-400">{feature.description}</p>
                </div>
              </div>
            ))}
          </div>
        </div>

        <div className="lg:w-1/2 relative">
          <div className="gradient-border p-1 rounded-2xl">
            <div className="bg-qgray rounded-2xl overflow-hidden">
              <div className="p-6 bg-qblack">
                <div className="flex justify-between items-center mb-6">
                  <div className="flex items-center space-x-3">
                    <div className="w-3 h-3 rounded-full bg-red-500"></div>
                    <div className="w-3 h-3 rounded-full bg-yellow-500"></div>
                    <div className="w-3 h-3 rounded-full bg-green-500"></div>
                  </div>
                  <span className="text-sm font-mono">From: InternationalBusinessMan.ETH</span>
                </div>

                <div className="mb-6">
                  <h3 className="text-xl font-bold mb-4">Initiate New Commodity Order</h3>

                  <div className="space-y-4">
                    <div>
                      <label className="block text-sm text-gray-400 mb-1">Seller ENS/Email</label>
                      <div className="bg-qgray rounded-lg p-3 flex items-center">
                        <input
                          type="text"
                          placeholder="seller.eth or seller@company.com"
                          className="bg-transparent w-full focus:outline-none"
                        />
                      </div>
                    </div>

                    <div>
                      <label className="block text-sm text-gray-400 mb-1">Commodity Type</label>
                      <div className="bg-qgray rounded-lg p-3">
                        <select className="bg-transparent w-full focus:outline-none">
                          <option>Crude Oil</option>
                          <option>Copper</option>
                          <option>Wheat</option>
                          <option>Natural Gas</option>
                          <option>Gold</option>
                        </select>
                      </div>
                    </div>

                    <div className="grid grid-cols-2 gap-4">
                      <div>
                        <label className="block text-sm text-gray-400 mb-1">Quantity</label>
                        <div className="bg-qgray rounded-lg p-3">
                          <input
                            type="number"
                            placeholder="1000"
                            className="bg-transparent w-full focus:outline-none"
                          />
                        </div>
                      </div>
                      <div>
                        <label className="block text-sm text-gray-400 mb-1">Unit</label>
                        <div className="bg-qgray rounded-lg p-3">
                          <select className="bg-transparent w-full focus:outline-none">
                            <option>Barrels</option>
                            <option>Tons</option>
                            <option>Bushels</option>
                            <option>Ounces</option>
                          </select>
                        </div>
                      </div>
                    </div>

                    <div>
                      <label className="block text-sm text-gray-400 mb-1">Delivery Date</label>
                      <div className="bg-qgray rounded-lg p-3">
                        <input type="date" className="bg-transparent w-full focus:outline-none" />
                      </div>
                    </div>
                  </div>
                </div>

                <button className="w-full py-3 rounded-lg bg-gradient-to-r from-qprimary to-qaccent text-qblack font-bold">
                  Send Request to Seller
                </button>
              </div>
            </div>
          </div>

          <div className="absolute -top-10 -left-10 w-40 h-40 rounded-full bg-qaccent opacity-10 blur-3xl"></div>
        </div>
      </div>
    </section>
  );
};

export default Features;
