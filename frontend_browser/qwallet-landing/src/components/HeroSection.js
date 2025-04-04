import React from 'react';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faGoogle, faEnvelope } from '@fortawesome/free-solid-svg-icons';

const HeroSection = () => {
  return (
    <section className="container mx-auto px-6 py-20">
      <div className="flex flex-col md:flex-row items-center">
        <div className="md:w-1/2 mb-12 md:mb-0">
          <h1 className="text-5xl md:text-6xl font-bold leading-tight mb-6">
            Commodity Finance <span className="gradient-text">Reinvented</span>
          </h1>
          <p className="text-xl text-gray-400 mb-8">
            The protocol that transforms invoices into working capital.
            Secure, efficient, and built for the modern commodity trader.
          </p>
          <div className="flex flex-col sm:flex-row space-y-4 sm:space-y-0 sm:space-x-4">
            <button className="google-btn px-6 py-3 rounded-lg bg-gradient-to-r from-qprimary to-qaccent text-qblack font-medium flex items-center justify-center">
              <FontAwesomeIcon icon={faGoogle} className="mr-3" />
              Sign Up with Google
            </button>
            <button className="px-6 py-3 rounded-lg border border-qgray hover:bg-qgray transition flex items-center justify-center">
              <FontAwesomeIcon icon={faEnvelope} className="mr-3" />
              Contact Sales
            </button>
          </div>
          <div className="mt-8 flex items-center space-x-4 text-gray-400">
            <div className="flex -space-x-2">
              {['.eth', '.xyz', '.wallet'].map((ext, idx) => (
                <div key={idx} className="w-10 h-10 rounded-full border-2 border-qgray bg-qgray flex items-center justify-center">
                  <span className="text-xs font-mono">{ext}</span>
                </div>
              ))}
            </div>
            <span>Trusted by institutional traders and suppliers</span>
          </div>
        </div>
        <div className="md:w-1/2 relative">
          <div className="gradient-border p-1 rounded-xl">
            <div className="bg-qgray rounded-xl p-6">
              <div className="flex justify-between items-center mb-6">
                <div className="flex items-center space-x-2">
                  <div className="w-3 h-3 rounded-full bg-red-500"></div>
                  <div className="w-3 h-3 rounded-full bg-yellow-500"></div>
                  <div className="w-3 h-3 rounded-full bg-green-500"></div>
                </div>
                <span className="text-sm font-mono">InternationalBusinessMan.ETH</span>
              </div>
              <div className="bg-qblack rounded-lg p-4 mb-4">
                <div className="flex justify-between items-center mb-2">
                  <span className="text-sm text-gray-400">Current Order Volume</span>
                  <FontAwesomeIcon icon={faEllipsisH} className="text-gray-400" />
                </div>
                <div className="flex items-end space-x-2">
                  <span className="text-3xl font-bold">1,230,033 USDC</span>
                  <span className="text-green-500 text-sm">+2 orders</span>
                </div>
              </div>
              <div className="grid grid-cols-3 gap-4 mb-6">
                {[
                  { icon: 'file-invoice', label: 'Invoices' },
                  { icon: 'exchange-alt', label: 'Transactions' },
                  { icon: 'chart-line', label: 'Analytics' },
                ].map((item, idx) => (
                  <div key={idx} className="bg-qblack rounded-lg p-3 text-center">
                    <div className="w-10 h-10 mx-auto mb-2 rounded-full bg-qgray flex items-center justify-center">
                      <FontAwesomeIcon icon={['fas', item.icon]} className="text-qaccent" />
                    </div>
                    <span className="text-xs">{item.label}</span>
                  </div>
                ))}
              </div>
              <div className="bg-qblack rounded-lg p-4">
                <div className="flex justify-between items-center mb-3">
                  <span className="text-sm font-medium">Recent Transactions</span>
                  <span className="text-xs text-gray-400">View All</span>
                </div>
                <div className="space-y-3">
                  {[
                    {
                      icon: 'box',
                      title: 'Copper Order',
                      user: 'metaltrader.eth',
                      amount: '800,000 USDC',
                    },
                    {
                      icon: 'gas-pump',
                      title: 'Crude Oil',
                      user: 'oilcompany.xyz',
                      amount: '430,033 USDC',
                    },
                  ].map((tx, idx) => (
                    <div key={idx} className="flex justify-between items-center">
                      <div className="flex items-center space-x-2">
                        <div className="w-8 h-8 rounded-full bg-qgray flex items-center justify-center">
                          <FontAwesomeIcon icon={['fas', tx.icon]} className="text-xs text-qaccent" />
                        </div>
                        <div>
                          <p className="text-sm font-medium">{tx.title}</p>
                          <p className="text-xs text-gray-400">{tx.user}</p>
                        </div>
                      </div>
                      <span className="text-sm font-mono">{tx.amount}</span>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          </div>
          <div className="absolute -bottom-6 -right-6 w-32 h-32 rounded-full bg-qprimary opacity-20 blur-3xl"></div>
        </div>
      </div>
    </section>
  );
};

export default HeroSection;
