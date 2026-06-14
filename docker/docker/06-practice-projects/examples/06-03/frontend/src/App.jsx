import { useState, useEffect } from 'react';

function App() {
  const [items, setItems] = useState([]);
  const [source, setSource] = useState('');
  const [title, setTitle] = useState('');
  const [health, setHealth] = useState(null);

  const fetchItems = async () => {
    const res = await fetch('/api/items');
    const json = await res.json();
    setItems(json.data || []);
    setSource(json.source || '');
  };

  const addItem = async () => {
    if (!title.trim()) return;
    await fetch('/api/items', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ title }),
    });
    setTitle('');
    fetchItems();
  };

  const checkHealth = async () => {
    try {
      const res = await fetch('/api/health');
      const json = await res.json();
      setHealth(json);
    } catch (err) {
      setHealth({ status: 'error', message: err.message });
    }
  };

  useEffect(() => {
    fetchItems();
    checkHealth();
  }, []);

  return (
    <div style={{ maxWidth: 600, margin: '40px auto', fontFamily: 'sans-serif' }}>
      <h1>Docker Fullstack Demo</h1>

      <div style={{ marginBottom: 20 }}>
        <h3>System Health</h3>
        <pre>{JSON.stringify(health, null, 2)}</pre>
      </div>

      <div style={{ marginBottom: 20 }}>
        <h3>Add Item</h3>
        <input
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          onKeyDown={(e) => e.key === 'Enter' && addItem()}
          placeholder="Enter item title..."
          style={{ padding: 8, width: 200, marginRight: 8 }}
        />
        <button onClick={addItem} style={{ padding: 8 }}>
          Add
        </button>
      </div>

      <div>
        <h3>Items (source: {source})</h3>
        <ul>
          {items.map((item) => (
            <li key={item.id}>
              {item.title} <small>({new Date(item.created_at).toLocaleString()})</small>
            </li>
          ))}
        </ul>
      </div>
    </div>
  );
}

export default App;
