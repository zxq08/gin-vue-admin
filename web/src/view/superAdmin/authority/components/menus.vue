<template>
  <div>
    <div class="clearflex">
      <el-button @click="relation" class="fl-right" size="small" type="primary">确 定</el-button>
    </div>
    <el-tree
      :data="menuInfo.menuTreeData"
      :default-checked-keys="menuInfo.menuTreeIds"
      :props="menuDefaultProps"
      @check="nodeChange"
      default-expand-all
      highlight-current
      node-key="ID"
      ref="menuTree"
      show-checkbox
    ></el-tree>
  </div>
</template>
<script>
import { getBaseMenuTree, getMenuAuthority, addMenuAuthority } from '@/api/menu'
import { ref, reactive, getCurrentInstance, onBeforeMount } from "vue";

export default {
  name: 'Menus',
  props: {
    row: {
      default: function() {
        return {}
      },
      type: Object
    }
  },
  setup(props) {
    const { ctx } = getCurrentInstance()
    const menuInfo = reactive({
        menuTreeData: [],
        menuTreeIds: []
      })
      const needConfirm = ref(false)
      const menuDefaultProps = reactive({
        children: 'children',
        label: function(data){
          return data.meta.title
        }
      })


      const nodeChange = () =>{
      needConfirm.value = true
    }
    // 暴露给外层使用的切换拦截统一方法
    const enterAndNext = () => {
      relation()
    }
    // 关联树 确认方法
    const relation = async () => {
      const checkArr = ctx.$refs.menuTree.getCheckedNodes(false, true)
      const res = await addMenuAuthority({
        menus: checkArr,
        authorityId: props.row.authorityId
      })
      if (res.code == 0) {
        ctx.$message({
          type: 'success',
          message: '菜单设置成功!'
        })
      }
    }

    const initMenu = async() => {
      // 获取所有菜单树
      const res = await getBaseMenuTree()
      menuInfo.menuTreeData = res.data.menus
      const res1 = await getMenuAuthority({ authorityId: props.row.authorityId })
      const menus = res1.data.menus
      const arr = []
      menus.map(item => {
        // 防止直接选中父级造成全选
        if (!menus.some(same => same.parentId === item.menuId)) {
          arr.push(Number(item.menuId))
        }
      })
      menuInfo.menuTreeIds = arr
    }
    onBeforeMount(()=>{
      initMenu()
    })
    return {
      menuInfo,
      menuDefaultProps,
      nodeChange,
      enterAndNext,
      relation
    }
  }
}
</script>
<style lang="scss">
</style>