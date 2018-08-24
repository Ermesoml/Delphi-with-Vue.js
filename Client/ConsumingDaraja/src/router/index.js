import Vue from 'vue'
import Router from 'vue-router'
import ListaCadastros from '@/components/ListaCadastros'

Vue.use(Router)

export default new Router({
  routes: [
    {
      path: '/',
      name: 'ListaCadastros',
      component: ListaCadastros
    }
  ]
})
