<template>
  <el-container class="layout-cont">
    <el-container :class="[isSider ? 'openside' : 'hideside', isMobile ? 'mobile' : '']">
      <el-row :class="[isShadowBg ? 'shadowBg' : '']" @click="changeShadow()"></el-row>
      <el-aside class="main-cont main-left">
        <div class="tilte">
          <img alt class="logoimg" src="~@/assets/nav_logo.png" />
          <h2 class="tit-text" v-if="isSider">Gin-Vue-Admin</h2>
        </div>
        <Aside class="aside" />
      </el-aside>
      <!-- 分块滑动功能 -->
      <el-main class="main-cont main-right">
        <transition
          :duration="{ enter: 800, leave: 100 }"
          mode="out-in"
          name="el-fade-in-linear"
        >
          <div
            :style="{
              width: `calc(100% - ${isMobile ? '0px' : isCollapse ? '54px' : '220px'})`,
            }"
            class="topfix"
          >
            <!-- :xs="8" :sm="6" :md="4" :lg="3" :xl="1" -->
            <el-row class="header-cont" :span="24">
              <el-col :xs="10" :lg="14" :md="14" :sm="9" :xl="14">
                <el-breadcrumb class="breadcrumb" separator-class="el-icon-arrow-right">
                  <el-breadcrumb-item
                    :key="item.path"
                    v-for="item in matched.slice(1, matched.length)"
                    >{{ item.meta.title }}</el-breadcrumb-item
                  >
                </el-breadcrumb>
              </el-col>
              <el-col :xs="2" :lg="1" :md="1" :sm="1" :xl="1">
                <div style="visibility:hidden" @click="totalCollapse" class="menu-total">
                  <i class="el-icon-s-unfold" v-if="isCollapse"></i>
                  <i class="el-icon-s-fold" v-else></i>
                </div>
              </el-col>
              <el-col :xs="12" :lg="9" :md="9" :sm="14" :xl="9">
                <div class="fl-right right-box">
                  <Search />
                  <Screenfull class="screenfull" :style="{cursor:'pointer'}"></Screenfull>
                  <el-dropdown>
                    <span class="header-avatar">
                      <CustomPic />
                      <span style="margin-left: 5px">{{ userInfo.nickName }}</span>
                      <i class="el-icon-arrow-down"></i>
                    </span>
                    <template #dropdown>
                      <el-dropdown-menu class="dropdown-group">
                        <el-dropdown-item>
                          <span>
                            更多信息
                            <el-badge is-dot />
                          </span>
                        </el-dropdown-item>
                        <el-dropdown-item @click="toPerson" icon="el-icon-s-custom"
                          >个人信息</el-dropdown-item
                        >
                        <el-dropdown-item @click="LoginOut" icon="el-icon-table-lamp"
                          >登 出</el-dropdown-item
                        >
                      </el-dropdown-menu>
                    </template>
                  </el-dropdown>
                </div>
              </el-col>
            </el-row>
            <!-- 当前面包屑用路由自动生成可根据需求修改 -->
            <!--
            :to="{ path: item.path }" 暂时注释不用-->
            <HistoryComponent />
          </div>
        </transition>

        <router-view
          :key="route.fullPath"
          v-slot="{ Component }"
          v-loading="loadingFlag"
          element-loading-text="正在加载中"
          class="admin-box"
          v-if="route.meta.keepAlive && reloadFlag"
        >
          <keep-alive>
            <component :is="Component" />
          </keep-alive>
        </router-view>
        <router-view
          :key="route.fullPath"
          v-slot="{ Component }"
          v-loading="loadingFlag"
          element-loading-text="正在加载中"
          class="admin-box"
          v-if="!route.meta.keepAlive && reloadFlag"
        >
          <component :is="Component" />
        </router-view>
        <BottomInfo />
      </el-main>
    </el-container>
  </el-container>
</template>

<script>
import Aside from "@/view/layout/aside";
import HistoryComponent from "@/view/layout/aside/historyComponent/history";
import Screenfull from "@/view/layout/screenfull";
import Search from "@/view/layout/search/search";
import BottomInfo from "@/view/layout/bottomInfo/bottomInfo";
import { useStore } from "vuex";
import CustomPic from "@/components/customPic";
import { emitter } from "@/utils/mitt";
import { computed, onMounted, ref, getCurrentInstance } from "vue";
import { useRoute, useRouter } from "vue-router";

export default {
  name: "Layout",
  components: {
    Aside,
    HistoryComponent,
    Screenfull,
    Search,
    BottomInfo,
    CustomPic,
  },
  setup() {
    const { ctx } = getCurrentInstance();
    const store = useStore();
    const router = useRouter();
    const route = useRoute()
    const show = ref(false);
    const isCollapse = ref(true);
    const isSider = ref(false);
    const isMobile = ref(false);
    const isShadowBg = ref(false);
    const loadingFlag = ref(false);
    const reloadFlag = ref(true);
    const value = ref("");
    const LoginOut = () => store.dispatch("user/LoginOut");
    const userInfo = computed(() => store.getters["user/userInfo"]);
    const title = computed(() => route.meta.title || "当前页面");
    const matched = computed(() => route.matched);
    const totalCollapse = () => {
      isCollapse.value = !isCollapse.value;
      isSider.value = !isCollapse.value;
      isShadowBg.value = !isCollapse.value;
      emitter.emit("collapse", isCollapse.value);
    };
    const reload = () => {
      reloadFlag.value = false
      ctx.$nextTick(()=>{
        reloadFlag.value = true
      })
    }
    const toPerson = () => {
      router.push({ name: "person" });
    };
    const changeShadow = () => {
      isShadowBg.value = !isShadowBg.value;
      isSider.value = !!isCollapse.value;
      totalCollapse();
    };

    onMounted(() => {
      let screenWidth = document.body.clientWidth;
      if (screenWidth < 1000) {
        isMobile.value = true;
        isSider.value = false;
        isCollapse.value = true;
      } else if (screenWidth >= 1000 && screenWidth < 1200) {
        isMobile.value = false;
        isSider.value = false;
        isCollapse.value = true;
      } else {
        isMobile.value = false;
        isSider.value = true;
        isCollapse.value = false;
      }
      emitter.emit("collapse", isCollapse.value);
      emitter.emit("mobile", isMobile.value);
      emitter.on("showLoading", () => {
        loadingFlag.value = true;
      });
      emitter.on("reload", () => {
        reload()
      });
      emitter.on("closeLoading", () => {
        loadingFlag.value = false;
      });
      window.onresize = () => {
        return (() => {
          let screenWidth = document.body.clientWidth;
          if (screenWidth < 1000) {
            isMobile.value = true;
            isSider.value = false;
            isCollapse.value = true;
          } else if (screenWidth >= 1000 && screenWidth < 1200) {
            isMobile.value = false;
            isSider.value = false;
            isCollapse.value = true;
          } else {
            isMobile.value = false;
            isSider.value = true;
            isCollapse.value = false;
          }
          emitter.emit("collapse", isCollapse.value);
          emitter.emit("mobile", isMobile.value);
        })();
      };
    });
    return {
      show,
      isCollapse,
      isSider,
      isMobile,
      isShadowBg,
      loadingFlag,
      value,
      LoginOut,
      userInfo,
      title,
      matched,
      totalCollapse,
      toPerson,
      changeShadow,
      route,
      reloadFlag
    };
  },
};
</script>
<style lang="scss">
@import "@/style/mobile.scss";
</style>
