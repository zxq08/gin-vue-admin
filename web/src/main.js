import { createApp } from 'vue'
import App from './App.vue'
// 路由守卫
import ElementPlus from 'element-plus';
import 'element-plus/lib/theme-chalk/index.css';

// 引入封装的router
import router from '@/router/index'

import '@/permission'
import { store } from '@/store/index'


// 富文本插件
import VueQuillEditor from 'vue-quill-editor'
import 'quill/dist/quill.core.css'
import 'quill/dist/quill.snow.css'
import 'quill/dist/quill.bubble.css'

// markdown插件
import mavonEditor from 'mavon-editor'
import 'mavon-editor/dist/css/index.css'

console.log(`
       欢迎使用 Gin-Vue-Admin
       当前版本:V2.3.8
       默认自动化文档地址:http://127.0.0.1%s/swagger/index.html
       默认前端文件运行地址:http://127.0.0.1:8080
       如果项目让您获得了收益，希望您能请团队喝杯可乐:https://www.gin-vue-admin.com/docs/coffee
`)
export default
createApp(App)
    .use(store)
    .use(router)
    .use(VueQuillEditor)
    .use(mavonEditor)
    .use(ElementPlus)
    .mount('#app')