<template>
  <div class="router-history">
    <el-tabs
      :closable="!(historys.length==1&&route.name==defaultRouter)"
      @contextmenu.prevent="openContextMenu($event)"
      @tab-click="changeTab"
      @tab-remove="removeTab"
      type="card"
      v-model="activeValue"
    >
      <el-tab-pane
        :key="item.name + JSON.stringify(item.query)+JSON.stringify(item.params)"
        :label="item.meta.title"
        :name="item.name + JSON.stringify(item.query)+JSON.stringify(item.params)"
        :tab="item"
        v-for="item in historys"
      ></el-tab-pane>
    </el-tabs>

    <!--自定义右键菜单html代码-->
    <ul
      :style="{ left: left + 'px', top: top + 'px' }"
      class="contextmenu"
      v-show="contextMenuVisible"
    >
      <li @click="closeAll">关闭所有</li>
      <li @click="closeLeft">关闭左侧</li>
      <li @click="closeRight">关闭右侧</li>
      <li @click="closeOther">关闭其他</li>
    </ul>
  </div>
</template>
<script>
import { emitter } from "@/utils/mitt";
import { onUnmounted, reactive, ref, watch, computed } from "vue";
import { useRoute, useRouter } from "vue-router";
import { useStore } from "vuex";
export default {
  name: "HistoryComponent",
  setup() {
    const store = useStore()
    const route = useRoute();
    const router = useRouter();
    const historys = reactive([]);
    const activeValue = ref("");
    const contextMenuVisible = ref(false);
    const left = ref(0);
    const top = ref(0);
    const isCollapse = ref(false);
    const isMobile = ref(false);
    const rightActive = ref("");

    const defaultRouter = computed(() => {
      const userInfo = store.getters["user/userInfo"]
      return userInfo.authority.defaultRouter
    })

    const openContextMenu = (e) => {
      if (historys.length == 1 && route.name == defaultRouter.value) {
        return false;
      }
      if (e.srcElement.id) {
        contextMenuVisible.value = true;
        let width;
        if (isCollapse.value) {
          width = 54;
        } else {
          width = 220;
        }
        if (isMobile.value) {
          width = 0;
        }
        left.value = e.clientX - width;
        top.value = e.clientY + 10;
        rightActive.value = e.srcElement.id.split("-")[1];
      }
    };
    const closeAll = () => {
      historys.length = 0;
      historys.push({
        name: defaultRouter.value,
        meta: {
          title: "首页",
        },
          query: {},
          params: {}
      });
      router.push({ name: defaultRouter.value });
      contextMenuVisible.value = false;
      sessionStorage.setItem("historys", JSON.stringify(historys));
    };
    const closeLeft = () => {
      let right;
      const rightIndex = historys.findIndex((item) => {
        if (item.name +
            JSON.stringify(item.query) +
            JSON.stringify(item.params) ==
          rightActive.value) {
          right = item;
        }
        return item.name +
            JSON.stringify(item.query) +
            JSON.stringify(item.params) ==
          rightActive.value;
      });
      const activeIndex = historys.findIndex((item) => item.name +
            JSON.stringify(item.query) +
            JSON.stringify(item.params) ==
          activeValue.value);
      historys.splice(0, rightIndex);
      if (rightIndex > activeIndex) {
        router.push(right);
      }
      sessionStorage.setItem("historys", JSON.stringify(historys));
    };
    const closeRight = () => {
      let right;
      const leftIndex = historys.findIndex((item) => {
        if (item.name +
            JSON.stringify(item.query) +
            JSON.stringify(item.params) ==
          rightActive.value) {
          right = item;
        }
        return (
          item.name +
            JSON.stringify(item.query) +
            JSON.stringify(item.params) ==
          rightActive.value
        );
      });
      const activeIndex = historys.findIndex((item) => item.name +
            JSON.stringify(item.query) +
            JSON.stringify(item.params) ==
          activeValue.value);
      historys.splice(leftIndex + 1, historys.length);
      if (leftIndex < activeIndex) {
        router.push(right);
      }
      sessionStorage.setItem("historys", JSON.stringify(historys));
    };
    const closeOther = () => {
      let right;
      historys.length = 0;
      const bkHistory = historys.filter((item) => {
        if (
          item.name +
            JSON.stringify(item.query) +
            JSON.stringify(item.params) ==
          rightActive.value
        ) {
          right = item;
        }
        return (
          item.name +
            JSON.stringify(item.query) +
            JSON.stringify(item.params) ==
          rightActive.value
        );
      });
      Object.assign(historys, bkHistory);
      router.push(right);
      sessionStorage.setItem("historys", JSON.stringify(historys));
    };

    const isSame = (route1, route2) => {
      if (route1.name != route2.name) {
        return false;
      }
      for (let key in route1.query) {
        if (route1.query[key] != route2.query[key]) {
          return false;
        }
      }
      for (let key in route1.params) {
        if (route1.params[key] != route2.params[key]) {
          return false;
        }
      }
      return true;
    }


    const setTab = (route) => {
      if (!historys.some((item) => isSame(item,route))) {
        const obj = {};
        obj.name = route.name;
        obj.meta = route.meta;
        obj.query = route.query;
        obj.params = route.params;
        historys.push(obj);
      }
       window.sessionStorage.setItem(
        "activeValue",
        route.name +
          JSON.stringify(route.query) +
          JSON.stringify(route.params)
      );
    };
    const changeTab = (component) => {
      const tab = component.instance.attrs.tab;
      router.push({ name: tab.name, query: tab.query, params: tab.params });
    };
    const removeTab = (tab) => {
      const index = historys.findIndex((item) => item.name +
            JSON.stringify(item.query) +
            JSON.stringify(item.params) == tab);
      if (item.name +
            JSON.stringify(item.query) +
            JSON.stringify(item.params) == tab) {
        if (historys.length == 1) {
          router.push({ name: defaultRouter.value });
        } else {
          if (index < historys.length - 1) {
            router.push({
              name: historys[index + 1].name,
              query: historys[index + 1].query,
              params: historys[index + 1].params,
            });
          } else {
            router.push({
              name: historys[index - 1].name,
              query: historys[index - 1].query,
              params: historys[index - 1].params,
            });
          }
        }
      }
      historys.splice(index, 1);
    };

    const initFun = () => {
      emitter.on("mobile", (isMobileParams) => {
        isMobile.value = isMobileParams;
      });
      emitter.on("collapse", (isCollapseParams) => {
        isCollapse.value = isCollapseParams;
      });
      const initHistorys = [
        {
          name: defaultRouter.value,
          meta: {
            title: "首页",
          },
          query: {},
          params: {}
        },
      ];

      Object.assign(
        historys,
        JSON.parse(sessionStorage.getItem("historys")) || initHistorys
      );
      if(!window.sessionStorage.getItem("activeValue")){
        activeValue.value = route.name + JSON.stringify(route.query)+JSON.stringify(route.params)
      }else{
        activeValue.value = window.sessionStorage.getItem("activeValue");
      }
      
      setTab(route);
    };
    initFun();
    onUnmounted(() => {
      emitter.off("collapse");
      emitter.off("mobile");
    });

    watch(contextMenuVisible, () => {
      if (contextMenuVisible.value) {
        document.body.addEventListener("click", () => {
          contextMenuVisible.value = false;
        });
      } else {
        document.body.removeEventListener("click", () => {
          contextMenuVisible.value = false;
        });
      }
    });

    watch(route, (to, now) => {
      const bkHistory = historys.filter((item) => !item.meta.closeTab)
      historys.length = 0
      Object.assign(historys,bkHistory)
      setTab(to);
      sessionStorage.setItem("historys", JSON.stringify(historys))
      activeValue.value = window.sessionStorage.getItem("activeValue")
    });

    return {
      historys,
      activeValue,
      contextMenuVisible,
      left,
      top,
      isCollapse,
      isMobile,
      rightActive,
      openContextMenu,
      closeAll,
      closeLeft,
      closeRight,
      closeOther,
      setTab,
      changeTab,
      removeTab,
      defaultRouter,
      route
    };
  }
};
</script>
<style lang="scss">
.contextmenu {
  width: 100px;
  margin: 0;
  border: 1px solid #ccc;
  background: #fff;
  z-index: 3000;
  position: absolute;
  list-style-type: none;
  padding: 5px 0;
  border-radius: 4px;
  font-size: 14px;
  color: #333;
  box-shadow: 2px 2px 3px 0 rgba(0, 0, 0, 0.2);
}
.contextmenu li {
  margin: 0;
  padding: 7px 16px;
}
.contextmenu li:hover {
  background: #f2f2f2;
  cursor: pointer;
}
</style>
