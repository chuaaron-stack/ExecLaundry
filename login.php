<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Login - Executive Laundry Verdant</title>
  <link rel="stylesheet" href="styles.css" />
  <style>
    .cursor-follower {
      position: fixed;
      width: 20px;
      height: 20px;
      background: rgba(76, 175, 80, 0.5);
      border-radius: 50%;
      pointer-events: none;
      z-index: 9999;
      transition: transform 0.1s ease;
    }
    .parallax-bg {
      position: fixed;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      background: url('executive-laundry-services.jpg') no-repeat center center;
      background-size: 140%;
      filter: none;
      z-index: -1;
    }

  </style>
</head>
<body>
  <div class="parallax-bg"></div>
  <header>
    <div class="header-content" style="background-color: #4caf50; padding: 30px 20px; text-align: center; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; text-shadow: 2px 2px 4px rgba(0,0,0,0.6);">
      <h1 style="font-size: 4.5rem; font-weight: 900; color: white; margin: 0; letter-spacing: 3px; font-style: italic;">Executive Laundry Verdant</h1>
    </div>
  </header>
  <main style="display: flex; justify-content: center; align-items: center; min-height: calc(100vh - 120px);">
    <div class="login-container">
      <h2>Log In</h2>
      <p style="margin-bottom:18px; color:#bfc9d1;">Please enter your username and password to access your account.</p>
      <form id="loginForm" class="login-form">
        <label for="username">Username</label>
        <input type="text" id="username" name="username" required class="login-input" />
        <label for="password">Password</label>
        <input type="password" id="password" name="password" required class="login-input" />
        <button type="submit" class="login-btn">Log In</button>
        <p id="loginError" class="login-error">Invalid username or password.</p>
      </form>
    </div>
  </main>
  <footer>
    &copy; 2025 Company Name. All rights reserved.
  </footer>

  <script>
    const loginForm = document.getElementById('loginForm');
    const loginError = document.getElementById('loginError');
    const loginBtn = document.querySelector('.login-btn');

    loginForm.addEventListener('submit', async (e) => {
      e.preventDefault();
      loginError.style.display = 'none';
      loginBtn.disabled = true;
      loginBtn.textContent = 'Logging In...';
      loginBtn.classList.add('loading');

      const username = document.getElementById('username').value;
      const password = document.getElementById('password').value;

      try {
        const response = await fetch('http://localhost:8000/api/login', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({ username, password })
        });

        const data = await response.json();

        if (data.success) {
          localStorage.setItem('isLoggedIn', 'true');
          localStorage.setItem('token', data.token);
          localStorage.setItem('user', JSON.stringify(data.user));
          loginError.style.display = 'none';
          animatePageFade();
          setTimeout(() => window.location.href = 'index.php', 500);
        } else {
          loginError.textContent = data.message;
          loginError.style.display = 'block';
          loginBtn.disabled = false;
          loginBtn.textContent = 'Log In';
          loginBtn.classList.remove('loading');
        }
      } catch (error) {
        console.error('Login error:', error);
        loginBtn.disabled = false;
        loginBtn.textContent = 'Log In';
        loginBtn.classList.remove('loading');
      }
    });

    // Check authentication status
    const user = JSON.parse(localStorage.getItem('user') || 'null');

    if (user && user.userId) {
      // User is logged in, redirect to dashboard
      window.location.href = 'index.php';
    }

    const inputs = loginForm.querySelectorAll('input');
    inputs.forEach(input => {
      input.addEventListener('focus', () => animateInputFocus(input));
      input.addEventListener('blur', () => removeInputFocus(input));
    });

    // Cursor follower and parallax effect
    const follower = document.createElement('div');
    follower.classList.add('cursor-follower');
    document.body.appendChild(follower);

    const parallaxBg = document.querySelector('.parallax-bg');

    document.addEventListener('mousemove', (e) => {
      follower.style.left = e.clientX - 10 + 'px';
      follower.style.top = e.clientY - 10 + 'px';

      // Parallax effect
      const x = (e.clientX / window.innerWidth - 0.5) * 50;
      const y = (e.clientY / window.innerHeight - 0.5) * 50;
      parallaxBg.style.backgroundPosition = `${50 + x}% ${50 + y}%`;
    });

    // Animation functions
    function animateInputFocus(input) {
      input.style.boxShadow = '0 0 8px rgba(76, 175, 80, 0.5)';
      input.style.borderColor = '#4CAF50';
    }

    function removeInputFocus(input) {
      input.style.boxShadow = '';
      input.style.borderColor = '#ccc';
    }

    function animatePageFade() {
      document.body.style.transition = 'opacity 0.5s ease';
      document.body.style.opacity = '0';
    }
  </script>

</body>
</html>
