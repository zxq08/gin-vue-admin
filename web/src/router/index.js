import { createRouter, createWebHashHistory } from 'vue-router'

const routes = [{
        path: '/',
        redirect: '/login'
    },
    {
        path: '/login',
        name: 'login',
        component: () =>
            import ('@/view/login/login.vue')
    }
]

const router = createRouter({
    history: createWebHashHistory(),
    routes
})

export default router