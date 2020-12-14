<template>
  <div>
    <el-scrollbar style="height:calc(100vh - 64px)">
      <transition :duration="{ enter: 800, leave: 100 }" mode="out-in" name="el-fade-in-linear">
        <el-menu
          :collapse="isCollapse"
          :collapse-transition="false"
          :default-active="active"
          @select="selectMenuItem"
          active-text-color="#fff"
          class="el-menu-vertical"
          text-color="rgb(191, 203, 217)"
          unique-opened
        >
          <template v-for="item in asyncRouters[0].children">
            <aside-component :key="item.name" :routerInfo="item" v-if="!item.hidden" />
          </template>
        </el-menu>
      </transition>
    </el-scrollbar>
  </div>
</template>

<script>
import { useStore } from "vuex";
import AsideComponent from "@/view/layout/aside/asideComponent";
import { emitter } from '@/utils/mitt'
import { computed, ref ,watch,onUnmounted } from 'vue';
import { useRoute, useRouter } from 'vue-router';
export default {
  name: "Aside",
  components: {
    AsideComponent
  },
  setup(){
    const store = useStore()
    const router = useRouter()
    const route = useRoute()
    const active = ref("")
    const isCollapse = ref(false)
    const addHistory = () => store.commit('history/addHistory')
    const asyncRouters = computed(()=>store.getters["router/asyncRouters"])
    const selectMenuItem = (index, _, ele) => {
      const query = {};
      const params = {};
      ele.route.parameters &&
        ele.route.parameters.map(item => {
          if (item.type == "query") {
            query[item.key] = item.value;
          } else {
            params[item.key] = item.value;
          }
        });
      if (index === route.name) return;
      if (index.indexOf("http://") > -1 || index.indexOf("https://") > -1) {
        window.open(index);
      } else {
        active.value = index
        router.push({ name: index, query, params });
      }
    }

    watch(route, () => {
      active.value = route.name;
    })

    onUnmounted(() => {
      emitter.off("collapse")
    })
    return{
      active,
      isCollapse,
      addHistory,
      selectMenuItem,
      asyncRouters
    }
  },
};
</script>

<style lang="scss">
.el-scrollbar {
  .el-scrollbar__view {
    height: 100%;
  }
}
.menu-info {
  .menu-contorl {
    line-height: 52px;
    font-size: 20px;
    display: table-cell;
    vertical-align: middle;
  }
}
</style>