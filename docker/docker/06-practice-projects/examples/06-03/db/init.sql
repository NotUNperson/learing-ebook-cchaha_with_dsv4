-- 这个文件在 PostgreSQL 容器首次启动时自动执行
CREATE TABLE IF NOT EXISTS items (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 插入一些示例数据
INSERT INTO items (title) VALUES
    ('Learn Docker'),
    ('Build a REST API'),
    ('Deploy to production');
