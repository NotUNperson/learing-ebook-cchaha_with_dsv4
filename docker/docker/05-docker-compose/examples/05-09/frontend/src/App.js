const API_BASE = '/api';

async function loadTodos() {
  const res = await fetch(`${API_BASE}/todos`);
  const todos = await res.json();
  const list = document.getElementById('todo-list');
  list.innerHTML = '';
  todos.forEach(todo => {
    const li = document.createElement('li');
    if (todo.completed) li.className = 'completed';
    li.innerHTML = `
      <span onclick="toggleTodo(${todo.id}, ${!todo.completed})" style="cursor:pointer;">${todo.title}</span>
      <button onclick="deleteTodo(${todo.id})" style="background:#ef4444;padding:4px 10px;font-size:12px;">删除</button>
    `;
    list.appendChild(li);
  });
}

async function addTodo() {
  const input = document.getElementById('todo-input');
  const title = input.value.trim();
  if (!title) return;
  await fetch(`${API_BASE}/todos`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ title })
  });
  input.value = '';
  loadTodos();
}

async function toggleTodo(id, completed) {
  await fetch(`${API_BASE}/todos/${id}`, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ completed })
  });
  loadTodos();
}

async function deleteTodo(id) {
  await fetch(`${API_BASE}/todos/${id}`, { method: 'DELETE' });
  loadTodos();
}

async function checkHealth() {
  try {
    const res = await fetch('/api/health');
    const data = await res.json();
    document.getElementById('status-text').textContent =
      'API ' + data.status + ' | DB ' + data.db;
  } catch (e) {
    document.getElementById('status-text').textContent = 'API offline';
  }
}

document.getElementById('todo-input').addEventListener('keypress', (e) => {
  if (e.key === 'Enter') addTodo();
});

loadTodos();
checkHealth();
setInterval(checkHealth, 10000);
