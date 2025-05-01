import { useState, useEffect, useRef } from 'react';
import { Camera, Download, Printer, Menu, X, Package, Home, Settings, ShoppingCart, Calendar, DollarSign } from 'lucide-react';
import html2canvas from 'html2canvas';

// PWA service worker registrace
if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('/service-worker.js').then(
      registration => console.log('ServiceWorker registration successful'),
      error => console.log('ServiceWorker registration failed:', error)
    );
  });
}

// Simulace backendu pomocí localStorage
const useLocalStorage = (key, initialValue) => {
  const [storedValue, setStoredValue] = useState(() => {
    try {
      const item = window.localStorage.getItem(key);
      return item ? JSON.parse(item) : initialValue;
    } catch (error) {
      console.error(error);
      return initialValue;
    }
  });

  const setValue = value => {
    try {
      const valueToStore = value instanceof Function ? value(storedValue) : value;
      setStoredValue(valueToStore);
      window.localStorage.setItem(key, JSON.stringify(valueToStore));
    } catch (error) {
      console.error(error);
    }
  };

  return [storedValue, setValue];
};

const App = () => {
  const invoiceRef = useRef(null);
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);
  const [activeTab, setActiveTab] = useState('home');
  // Lokální ukládání dat
  const [exchangeRate, setExchangeRate] = useLocalStorage('exchangeRate', 25);
  const [selectedVilla, setSelectedVilla] = useState('Amazing pool vila');
  const [guests, setGuests] = useState(1);
  const [nights, setNights] = useState(1);
  const [wellnessPrice, setWellnessPrice] = useState(0);
  const [cart, setCart] = useLocalStorage('cart', []);
  const [showInvoice, setShowInvoice] = useState(false);
  const [salesHistory, setSalesHistory] = useLocalStorage('salesHistory', []);
  const [darkMode, setDarkMode] = useLocalStorage('darkMode', false);
  
  // Inventář s persistencí
  const [inventory, setInventory] = useLocalStorage('inventory', {
    'Piña Colada': 10,
    'Fanta, Sprite, Coca Cola': 20,
    'Red Bull': 15,
    'Vitamin Water': 15,
    'Beer': 30,
    'Jack & Cola': 10,
    'Cin & Tonic': 10,
    'Mojito': 10,
    'Moscow Mule': 10,
    'Pivo sud 30 l': 3,
    'Pivo sud 50 l': 2,
    'Plyn': 5,
    'Gril': 2,
  });
  
  const [items, setItems] = useLocalStorage('items', {
    'Piña Colada': 4,
    'Fanta, Sprite, Coca Cola': 1.3,
    'Red Bull': 2.4,
    'Vitamin Water': 1.4,
    'Beer': 2.4,
    'Jack & Cola': 5,
    'Cin & Tonic': 3,
    'Mojito': 4,
    'Moscow Mule': 4,
    'Pivo sud 30 l': 125,
    'Pivo sud 50 l': 175,
    'Plyn': 12,
    'Gril': 20,
  });
  
  const villas = ['Amazing pool vila', 'Little castle vila', 'OH YEAH vila'];
  
  const addToCart = (item) => {
    if (inventory[item] > 0) {
      setCart([...cart, {
        name: item,
        price: items[item],
        villa: selectedVilla
      }]);
      
      const newInventory = {...inventory};
      newInventory[item]--;
      setInventory(newInventory);
    }
  };
  
  const addWellnessToCart = () => {
    if (wellnessPrice > 0) {
      setCart([...cart, {
        name: 'Wellness',
        price: parseFloat(wellnessPrice),
        villa: selectedVilla
      }]);
    }
  };
  
  const calculateCityTax = () => {
    return guests * nights * 2;
  };
  
  const calculateTotal = () => {
    const itemsTotal = cart.reduce((sum, item) => sum + item.price, 0);
    const cityTax = calculateCityTax();
    return itemsTotal + cityTax;
  };
  
  const generateInvoice = () => {
    setShowInvoice(true);
  };
  
  const closeInvoice = () => {
    setShowInvoice(false);
    setCart([]);
  };
  
  const exportToJPEG = () => {
    alert('Exportováno do JPEG (simulace)');
  };
  
  const editItemPrice = (item, newPrice) => {
    const updatedItems = {...items};
    updatedItems[item] = parseFloat(newPrice);
    setItems(updatedItems);
  };
  
  const editInventory = (item, newCount) => {
    const updatedInventory = {...inventory};
    updatedInventory[item] = parseInt(newCount);
    setInventory(updatedInventory);
  };
  
  const removeFromCart = (index) => {
    const removedItem = cart[index];
    const newCart = cart.filter((_, i) => i !== index);
    setCart(newCart);
    
    const newInventory = {...inventory};
    newInventory[removedItem.name]++;
    setInventory(newInventory);
  };

  // Export faktury do JPEG
  const exportToJPEG = async () => {
    if (invoiceRef.current) {
      try {
        const canvas = await html2canvas(invoiceRef.current);
        const image = canvas.toDataURL('image/jpeg', 1.0);
        const link = document.createElement('a');
        link.download = `faktura-${new Date().toISOString().slice(0, 10)}.jpg`;
        link.href = image;
        link.click();
      } catch (err) {
        console.error('Chyba při exportu do JPEG:', err);
        alert('Chyba při exportu faktury.');
      }
    }
  };

  // Funkce pro tisk faktury
  const printInvoice = () => {
    window.print();
  };

  // Uložení prodeje do historie
  const saveSale = () => {
    const sale = {
      id: Date.now(),
      date: new Date().toISOString(),
      items: [...cart],
      villa: selectedVilla,
      guests,
      nights,
      cityTax: calculateCityTax(),
      total: calculateTotal(),
      exchangeRate
    };
    
    setSalesHistory([...salesHistory, sale]);
    setShowInvoice(false);
    setCart([]);
    alert('Prodej byl úspěšně uložen!');
  };
  
  // Přidání nové položky do nabídky
  const [newItemName, setNewItemName] = useState('');
  const [newItemPrice, setNewItemPrice] = useState('');
  const [newItemCount, setNewItemCount] = useState('');
  
  const addNewItem = () => {
    if (newItemName && newItemPrice && newItemCount) {
      const updatedItems = {...items};
      updatedItems[newItemName] = parseFloat(newItemPrice);
      setItems(updatedItems);
      
      const updatedInventory = {...inventory};
      updatedInventory[newItemName] = parseInt(newItemCount);
      setInventory(updatedInventory);
      
      setNewItemName('');
      setNewItemPrice('');
      setNewItemCount('');
    }
  };
  
  return (
    <div className={`${darkMode ? 'bg-gray-900 text-white' : 'bg-gray-100'} min-h-screen transition-colors duration-300`}>
      <nav className="bg-blue-600 text-white">
        <div className="container mx-auto px-4">
          <div className="flex justify-between items-center py-3">
            <div className="flex items-center">
              <span className="text-xl font-bold">Kasa Pro</span>
            </div>
            
            <div className="hidden md:flex items-center space-x-6">
              <button 
                onClick={() => setActiveTab('home')} 
                className={`flex items-center ${activeTab === 'home' ? 'font-bold' : ''}`}
              >
                <Home className="w-5 h-5 mr-1" /> Domů
              </button>
              <button 
                onClick={() => setActiveTab('inventory')} 
                className={`flex items-center ${activeTab === 'inventory' ? 'font-bold' : ''}`}
              >
                <Package className="w-5 h-5 mr-1" /> Sklad
              </button>
              <button 
                onClick={() => setActiveTab('sales')} 
                className={`flex items-center ${activeTab === 'sales' ? 'font-bold' : ''}`}
              >
                <DollarSign className="w-5 h-5 mr-1" /> Prodeje
              </button>
              <button 
                onClick={() => setActiveTab('settings')} 
                className={`flex items-center ${activeTab === 'settings' ? 'font-bold' : ''}`}
              >
                <Settings className="w-5 h-5 mr-1" /> Nastavení
              </button>
            </div>
            
            <button 
              className="md:hidden" 
              onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
            >
              {isMobileMenuOpen ? <X className="w-6 h-6" /> : <Menu className="w-6 h-6" />}
            </button>
          </div>
        </div>
        
        {isMobileMenuOpen && (
          <div className="md:hidden bg-blue-700 p-4">
            <div className="flex flex-col space-y-3">
              <button 
                onClick={() => { setActiveTab('home'); setIsMobileMenuOpen(false); }} 
                className="flex items-center"
              >
                <Home className="w-5 h-5 mr-2" /> Domů
              </button>
              <button 
                onClick={() => { setActiveTab('inventory'); setIsMobileMenuOpen(false); }} 
                className="flex items-center"
              >
                <Package className="w-5 h-5 mr-2" /> Sklad
              </button>
              <button 
                onClick={() => { setActiveTab('sales'); setIsMobileMenuOpen(false); }} 
                className="flex items-center"
              >
                <DollarSign className="w-5 h-5 mr-2" /> Prodeje
              </button>
              <button 
                onClick={() => { setActiveTab('settings'); setIsMobileMenuOpen(false); }} 
                className="flex items-center"
              >
                <Settings className="w-5 h-5 mr-2" /> Nastavení
              </button>
            </div>
          </div>
        )}
      </nav>
      
      <main className="container mx-auto py-6 px-4">
      {!showInvoice ? (
        <>
        {activeTab === 'home' && (
          <div>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-6">
              <div className={`${darkMode ? 'bg-gray-800' : 'bg-white'} p-6 rounded-lg shadow-lg`}>
                <h2 className="text-xl font-semibold mb-4">Nastavení objednávky</h2>
              
              <div className="mb-4">
                <label className="block mb-2 font-medium">Kurz EUR/CZK:</label>
                <input 
                  type="number"
                  value={exchangeRate}
                  onChange={(e) => setExchangeRate(e.target.value)}
                  className={`${darkMode ? 'bg-gray-700 border-gray-600' : 'bg-white border-gray-300'} border p-2 w-full rounded focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors`}
                />
              </div>
              
              <div className="mb-4">
                <label className="block mb-2 font-medium">Vila:</label>
                <div className="relative">
                  <select 
                    value={selectedVilla}
                    onChange={(e) => setSelectedVilla(e.target.value)}
                    className={`${darkMode ? 'bg-gray-700 border-gray-600' : 'bg-white border-gray-300'} border p-2 w-full rounded appearance-none pr-8 focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors`}
                  >
                    {villas.map(villa => (
                      <option key={villa} value={villa}>{villa}</option>
                    ))}
                  </select>
                  <div className="absolute inset-y-0 right-0 flex items-center px-2 pointer-events-none">
                    <svg className="w-4 h-4 fill-current" viewBox="0 0 20 20">
                      <path d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z"></path>
                    </svg>
                  </div>
                </div>
              </div>
              
              <div className="mb-4">
                <label className="block mb-2 font-medium">Počet hostů:</label>
                <input 
                  type="number"
                  value={guests}
                  onChange={(e) => setGuests(parseInt(e.target.value) || 1)}
                  className={`${darkMode ? 'bg-gray-700 border-gray-600' : 'bg-white border-gray-300'} border p-2 w-full rounded focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors`}
                  min="1"
                />
              </div>
              
              <div className="mb-4">
                <label className="block mb-2 font-medium">Počet nocí:</label>
                <input 
                  type="number"
                  value={nights}
                  onChange={(e) => setNights(parseInt(e.target.value) || 1)}
                  className={`${darkMode ? 'bg-gray-700 border-gray-600' : 'bg-white border-gray-300'} border p-2 w-full rounded focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors`}
                  min="1"
                />
              </div>
              
              <div>
                <label className="block mb-2 font-medium">Cena za wellness (€):</label>
                <div className="flex">
                  <input 
                    type="number"
                    value={wellnessPrice}
                    onChange={(e) => setWellnessPrice(e.target.value)}
                    className={`${darkMode ? 'bg-gray-700 border-gray-600' : 'bg-white border-gray-300'} border p-2 w-full rounded-l focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors`}
                    min="0"
                    step="0.1"
                  />
                  <button 
                    onClick={addWellnessToCart}
                    className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-r transition-colors"
                  >
                    Přidat
                  </button>
                </div>
              </div>
            </div>
            
            <div className={`${darkMode ? 'bg-gray-800' : 'bg-white'} p-6 rounded-lg shadow-lg`}>
              <h2 className="text-xl font-semibold mb-4">Nabídka</h2>
              
              <div className="overflow-y-auto max-h-96">
                <table className="w-full border-collapse">
                  <thead>
                    <tr className="bg-gray-100">
                      <th className="p-2 text-left">Položka</th>
                      <th className="p-2 text-left">Cena (€)</th>
                      <th className="p-2 text-left">Cena (Kč)</th>
                      <th className="p-2 text-left">Sklad</th>
                      <th className="p-2 text-left">Akce</th>
                    </tr>
                  </thead>
                  <tbody>
                    {Object.keys(items).map(item => (
                      <tr key={item} className="border-b">
                        <td className="p-2">{item}</td>
                        <td className="p-2">
                          <input 
                            type="number" 
                            value={items[item]} 
                            onChange={(e) => editItemPrice(item, e.target.value)}
                            className="border p-1 w-16"
                            step="0.1"
                          />
                        </td>
                        <td className="p-2">{(items[item] * exchangeRate).toFixed(0)}</td>
                        <td className="p-2">
                          <input 
                            type="number" 
                            value={inventory[item]} 
                            onChange={(e) => editInventory(item, e.target.value)}
                            className="border p-1 w-16"
                          />
                        </td>
                        <td className="p-2">
                          <button 
                            onClick={() => addToCart(item)}
                            className="bg-blue-500 text-white px-2 py-1 rounded"
                            disabled={inventory[item] <= 0}
                          >
                            +
                          </button>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        )}
        
        {activeTab === 'sales' && (
          <div className={`${darkMode ? 'bg-gray-800' : 'bg-white'} p-6 rounded-lg shadow-lg`}>
            <h2 className="text-xl font-semibold mb-4">Historie prodejů</h2>
            
            {salesHistory.length > 0 ? (
              <div className="overflow-y-auto max-h-screen-75 scrollbar-thin scrollbar-thumb-blue-500 scrollbar-track-gray-200">
                <table className="w-full border-collapse">
                  <thead>
                    <tr className={`${darkMode ? 'bg-gray-700' : 'bg-blue-50'} sticky top-0`}>
                      <th className="p-3 text-left font-semibold">Datum</th>
                      <th className="p-3 text-left font-semibold">Vila</th>
                      <th className="p-3 text-left font-semibold">Hosté</th>
                      <th className="p-3 text-left font-semibold">Počet nocí</th>
                      <th className="p-3 text-left font-semibold">Celkem (€)</th>
                      <th className="p-3 text-left font-semibold">Celkem (Kč)</th>
                      <th className="p-3 text-left font-semibold">Akce</th>
                    </tr>
                  </thead>
                  <tbody>
                    {salesHistory.map((sale) => (
                      <tr key={sale.id} className={`${darkMode ? 'border-gray-700 hover:bg-gray-700' : 'border-gray-200 hover:bg-blue-50'} border-b transition-colors`}>
                        <td className="p-3">{new Date(sale.date).toLocaleDateString()}</td>
                        <td className="p-3">{sale.villa}</td>
                        <td className="p-3">{sale.guests}</td>
                        <td className="p-3">{sale.nights}</td>
                        <td className="p-3">{sale.total.toFixed(2)} €</td>
                        <td className="p-3">{(sale.total * sale.exchangeRate).toFixed(0)} Kč</td>
                        <td className="p-3">
                          <button 
                            className="bg-blue-500 hover:bg-blue-600 text-white px-3 py-1 rounded transition-colors mr-2"
                            onClick={() => {
                              // Zobrazit detail prodeje
                              const details = sale.items.map(item => `${item.name}: ${item.price} €`).join('\n');
                              alert(`Detail prodeje:\n${details}\nCity Tax: ${sale.cityTax} €\nCelkem: ${sale.total.toFixed(2)} €`);
                            }}
                          >
                            Detail
                          </button>
                          <button 
                            className="bg-red-500 hover:bg-red-600 text-white px-3 py-1 rounded transition-colors"
                            onClick={() => {
                              if (confirm('Opravdu chcete smazat tento prodej?')) {
                                setSalesHistory(salesHistory.filter(s => s.id !== sale.id));
                              }
                            }}
                          >
                            Smazat
                          </button>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            ) : (
              <p className="text-center py-6">Žádné prodeje k zobrazení</p>
            )}
          </div>
        )}
        
        {activeTab === 'settings' && (
          <div className={`${darkMode ? 'bg-gray-800' : 'bg-white'} p-6 rounded-lg shadow-lg`}>
            <h2 className="text-xl font-semibold mb-6">Nastavení aplikace</h2>
            
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div>
                <h3 className="text-lg font-medium mb-3">Základní nastavení</h3>
                
                <div className="mb-4">
                  <label className="flex items-center cursor-pointer">
                    <div className="relative">
                      <input 
                        type="checkbox" 
                        className="sr-only" 
                        checked={darkMode} 
                        onChange={() => setDarkMode(!darkMode)}
                      />
                      <div className={`block ${darkMode ? 'bg-blue-600' : 'bg-gray-300'} w-14 h-8 rounded-full transition-colors`}></div>
                      <div className={`dot absolute left-1 top-1 bg-white w-6 h-6 rounded-full transition transform ${darkMode ? 'translate-x-6' : 'translate-x-0'}`}></div>
                    </div>
                    <div className="ml-3 font-medium">Tmavý režim</div>
                  </label>
                </div>
                
                <div className="mb-4">
                  <label className="block mb-2 font-medium">Výchozí kurz EUR/CZK:</label>
                  <input 
                    type="number"
                    value={exchangeRate}
                    onChange={(e) => setExchangeRate(e.target.value)}
                    className={`${darkMode ? 'bg-gray-700 border-gray-600' : 'bg-white border-gray-300'} border p-2 w-full rounded focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors`}
                  />
                </div>
              </div>
              
              <div>
                <h3 className="text-lg font-medium mb-3">Správa dat</h3>
                
                <div className="mb-4">
                  <button 
                    className="bg-red-500 hover:bg-red-600 text-white px-4 py-2 rounded transition-colors w-full mb-3"
                    onClick={() => {
                      if (confirm('Opravdu chcete vymazat historii prodejů? Tato akce je nevratná!')) {
                        setSalesHistory([]);
                        alert('Historie prodejů byla vymazána.');
                      }
                    }}
                  >
                    Vymazat historii prodejů
                  </button>
                  
                  <button 
                    className="bg-yellow-500 hover:bg-yellow-600 text-white px-4 py-2 rounded transition-colors w-full mb-3"
                    onClick={() => {
                      if (confirm('Opravdu chcete resetovat inventář? Tato akce je nevratná!')) {
                        setInventory({
                          'Piña Colada': 10,
                          'Fanta, Sprite, Coca Cola': 20,
                          'Red Bull': 15,
                          'Vitamin Water': 15,
                          'Beer': 30,
                          'Jack & Cola': 10,
                          'Cin & Tonic': 10,
                          'Mojito': 10,
                          'Moscow Mule': 10,
                          'Pivo sud 30 l': 3,
                          'Pivo sud 50 l': 2,
                          'Plyn': 5,
                          'Gril': 2,
                        });
                        alert('Inventář byl resetován na výchozí hodnoty.');
                      }
                    }}
                  >
                    Resetovat inventář
                  </button>
                  
                  <button 
                    className="bg-green-600 hover:bg-green-700 text-white px-4 py-2 rounded transition-colors w-full"
                    onClick={() => {
                      try {
                        const data = {
                          salesHistory,
                          inventory,
                          items,
                          exchangeRate
                        };
                        const blob = new Blob([JSON.stringify(data, null, 2)], {type: 'application/json'});
                        const url = URL.createObjectURL(blob);
                        const a = document.createElement('a');
                        a.href = url;
                        a.download = `kasa-data-${new Date().toISOString().slice(0, 10)}.json`;
                        a.click();
                      } catch (err) {
                        console.error('Chyba při exportu dat:', err);
                        alert('Chyba při exportu dat.');
                      }
                    }}
                  >
                    Exportovat data
                  </button>
                </div>
              </div>
            </div>
          </div>
        )}
        
          <div className={`${darkMode ? 'bg-gray-800' : 'bg-white'} p-6 rounded-lg shadow-lg mt-6`}>
            <div className="flex justify-between items-center mb-4">
              <h2 className="text-xl font-semibold">Košík</h2>
              <span className={`${darkMode ? 'bg-blue-900' : 'bg-blue-100'} text-blue-800 font-semibold py-1 px-3 rounded-full`}>
                {cart.length} položek
              </span>
            </div>
            
            {cart.length > 0 ? (
              <div>
                <div className="overflow-y-auto max-h-96 scrollbar-thin scrollbar-thumb-blue-500 scrollbar-track-gray-200">
                  <table className="w-full border-collapse mb-4">
                    <thead>
                      <tr className={`${darkMode ? 'bg-gray-700' : 'bg-blue-50'} sticky top-0`}>
                        <th className="p-3 text-left font-semibold">Položka</th>
                        <th className="p-3 text-left font-semibold">Vila</th>
                        <th className="p-3 text-left font-semibold">Cena (€)</th>
                        <th className="p-3 text-left font-semibold">Cena (Kč)</th>
                        <th className="p-3 text-left font-semibold">Akce</th>
                      </tr>
                    </thead>
                    <tbody>
                      {cart.map((item, index) => (
                        <tr key={index} className={`${darkMode ? 'border-gray-700 hover:bg-gray-700' : 'border-gray-200 hover:bg-blue-50'} border-b transition-colors`}>
                          <td className="p-3">{item.name}</td>
                          <td className="p-3">{item.villa}</td>
                          <td className="p-3">{item.price.toFixed(2)} €</td>
                          <td className="p-3">{(item.price * exchangeRate).toFixed(0)} Kč</td>
                          <td className="p-3">
                            <button 
                              onClick={() => removeFromCart(index)}
                              className="bg-red-500 hover:bg-red-600 text-white px-2 py-1 rounded transition-colors"
                            >
                              Odebrat
                            </button>
                          </td>
                        </tr>
                      ))}
                      <tr className={`${darkMode ? 'bg-gray-700' : 'bg-blue-50'}`}>
                        <td className="p-3 font-bold">City Tax</td>
                        <td className="p-3">Všechny vily</td>
                        <td className="p-3 font-bold">{calculateCityTax()} €</td>
                        <td className="p-3 font-bold">{(calculateCityTax() * exchangeRate).toFixed(0)} Kč</td>
                        <td className="p-3"></td>
                      </tr>
                      <tr className={`${darkMode ? 'bg-gray-600' : 'bg-blue-100'} font-bold`}>
                        <td className="p-3" colSpan="2">CELKEM</td>
                        <td className="p-3">{calculateTotal().toFixed(2)} €</td>
                        <td className="p-3">{(calculateTotal() * exchangeRate).toFixed(0)} Kč</td>
                        <td className="p-3"></td>
                      </tr>
                    </tbody>
                  </table>
                </div>
                
                <button 
                  onClick={generateInvoice}
                  className="bg-green-600 hover:bg-green-700 text-white px-6 py-3 rounded-lg font-semibold transition-colors w-full md:w-auto"
                >
                  <div className="flex items-center justify-center">
                    <ShoppingCart className="w-5 h-5 mr-2" />
                    Vytvořit fakturu
                  </div>
                </button>
              </div>
            ) : (
              <div className="text-center py-6">
                <ShoppingCart className={`w-16 h-16 mx-auto mb-4 ${darkMode ? 'text-gray-600' : 'text-gray-300'}`} />
                <p>Košík je prázdný</p>
              </div>
            )}
          </div>
        </>
      ) : (
        <div className="bg-white p-6 rounded-lg shadow">
          <h1 className="text-3xl font-bold mb-6 text-center">Faktura</h1>
          
          <div className="mb-6">
            <h2 className="text-xl font-semibold mb-2">Detaily</h2>
            <p>Vila: {selectedVilla}</p>
            <p>Počet hostů: {guests}</p>
            <p>Počet nocí: {nights}</p>
          </div>
          
          <table className="w-full border-collapse mb-6">
            <thead>
              <tr className="bg-gray-100">
                <th className="p-2 text-left">Položka</th>
                <th className="p-2 text-left">Vila</th>
                <th className="p-2 text-right">Cena (€)</th>
                <th className="p-2 text-right">Cena (Kč)</th>
              </tr>
            </thead>
            <tbody>
              {cart.map((item, index) => (
                <tr key={index} className="border-b">
                  <td className="p-2">{item.name}</td>
                  <td className="p-2">{item.villa}</td>
                  <td className="p-2 text-right">{item.price.toFixed(2)} €</td>
                  <td className="p-2 text-right">{(item.price * exchangeRate).toFixed(0)} Kč</td>
                </tr>
              ))}
              <tr className="bg-gray-50">
                <td className="p-2 font-bold">City Tax</td>
                <td className="p-2">Všechny vily</td>
                <td className="p-2 text-right font-bold">{calculateCityTax()} €</td>
                <td className="p-2 text-right font-bold">{(calculateCityTax() * exchangeRate).toFixed(0)} Kč</td>
              </tr>
              <tr className="bg-gray-200">
                <td className="p-2 font-bold" colSpan="2">CELKEM</td>
                <td className="p-2 text-right font-bold">{calculateTotal().toFixed(2)} €</td>
                <td className="p-2 text-right font-bold">{(calculateTotal() * exchangeRate).toFixed(0)} Kč</td>
              </tr>
            </tbody>
          </table>
          
          <div className="flex justify-between">
            <button 
              onClick={closeInvoice}
              className="bg-gray-500 text-white px-4 py-2 rounded"
            >
              Zpět
            </button>
            
            <button 
              onClick={exportToJPEG}
              className="bg-blue-600 text-white px-4 py-2 rounded"
            >
              Exportovat do JPEG
            </button>
          </div>
        </div>
      )}
    </div>
  );
};

export default App;
