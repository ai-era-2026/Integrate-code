/**
 * 工单系统登录检查
 * 防止退出登录后通过浏览器回退访问
 */

(function() {
    'use strict';

    // 检查登录状态
    function checkLoginStatus() {
        $.ajax({
            url: '/case/auth/check-login',
            method: 'GET',
            cache: false,
            success: function(response) {
                const isLoggedIn = response.success && response.data && response.data.user;

                if (!isLoggedIn) {
                    // 未登录，重定向到登录页面
                    console.log('User not logged in, redirecting to /case/');

                    // 显示加载提示
                    document.body.innerHTML = '<div style="display:flex;justify-content:center;align-items:center;height:100vh;background:#f5f5f5;"><h2 style="color:#666;">请先登录...</h2></div>';

                    // 跳转到登录页
                    setTimeout(function() {
                        window.location.href = '/case/?next=' + encodeURIComponent(window.location.pathname);
                    }, 500);
                } else {
                    console.log('User is logged in:', response.data.user.username);
                }
            },
            error: function(xhr) {
                console.error('Login status check failed:', xhr);
                // 检查失败时视为未登录
                document.body.innerHTML = '<div style="display:flex;justify-content:center;align-items:center;height:100vh;background:#f5f5f5;"><h2 style="color:#666;">请先登录...</h2></div>';
                setTimeout(function() {
                    window.location.href = '/case/?next=' + encodeURIComponent(window.location.pathname);
                }, 500);
            }
        });
    }

    // 页面加载后立即检查
    $(document).ready(function() {
        console.log('Case login checker initialized');

        // 短暂延迟确保一切准备就绪
        setTimeout(checkLoginStatus, 100);
    });

    // 定期检查登录状态（每5秒）
    setInterval(checkLoginStatus, 5000);

    // 页面可见性改变时检查（从后台切换回来）
    document.addEventListener('visibilitychange', function() {
        if (!document.hidden) {
            console.log('Page became visible, checking login status');
            checkLoginStatus();
        }
    });

    // 页面获得焦点时检查（从其他标签页切换回来）
    window.addEventListener('focus', function() {
        console.log('Page gained focus, checking login status');
        checkLoginStatus();
    });

    // 监听浏览器后退/前进按钮
    window.addEventListener('popstate', function() {
        console.log('Popstate event detected, checking login status');
        checkLoginStatus();
    });

    // 监听pageshow事件（处理缓存页面）
    window.addEventListener('pageshow', function(event) {
        // 如果是从缓存中恢复的页面
        if (event.persisted) {
            console.log('Page restored from cache, checking login status');
            checkLoginStatus();
        }
    });

})();

