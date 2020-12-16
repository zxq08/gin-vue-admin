<template>
  <div>
    <div class="search-term">
      <el-form :inline="true" :model="searchInfo" class="demo-form-inline">
        <el-form-item>
          <el-button @click="openDialog" type="primary">新增客户</el-button>
        </el-form-item>
      </el-form>
    </div>
    <el-table
      :data="tableData"
      border
      ref="multipleTable"
      stripe
      style="width: 100%"
      tooltip-effect="dark"
    >
      <el-table-column type="selection" width="55"></el-table-column>
      <el-table-column label="接入日期" width="180">
        <template #default="scope">{{ formatDate(scope.row.CreatedAt) }}</template>
      </el-table-column>
      <el-table-column label="姓名" prop="customerName" width="120"></el-table-column>
      <el-table-column
        label="电话"
        prop="customerPhoneData"
        width="120"
      ></el-table-column>
      <el-table-column label="接入人ID" prop="sysUserId" width="120"></el-table-column>
      <el-table-column label="按钮组" min-width="160">
        <template #default="scope">
          <el-button @click="updateCustomer(scope.row)" size="small" type="text"
            >变更</el-button
          >
          <el-popover placement="top" width="160" v-model="scope.row.visible">
            <p>确定要删除吗？</p>
            <div style="text-align: right; margin: 0">
              <el-button size="mini" type="text" @click="scope.row.visible = false"
                >取消</el-button
              >
              <el-button type="primary" size="mini" @click="deleteCustomer(scope.row)"
                >确定</el-button
              >
            </div>
            <template #reference>
              <el-button type="danger" icon="el-icon-delete" size="mini">删除</el-button>
            </template>
          </el-popover>
        </template>
      </el-table-column>
    </el-table>

    <el-pagination
      :current-page="page"
      :page-size="pageSize"
      :page-sizes="[10, 30, 50, 100]"
      :style="{ float: 'right', padding: '20px' }"
      :total="total"
      @current-change="handleCurrentChange"
      @size-change="handleSizeChange"
      layout="total, sizes, prev, pager, next, jumper"
    ></el-pagination>

    <el-dialog :close-on-click-modal="false" :before-close="closeDialog" v-model="dialogFormVisible" title="客户">
      <el-form class="gva-dialog-body" :inline="true" :model="form" label-width="80px">
        <el-form-item label="客户名">
          <el-input autocomplete="off" v-model="form.customerName"></el-input>
        </el-form-item>
        <el-form-item label="客户电话">
          <el-input autocomplete="off" v-model="form.customerPhoneData"></el-input>
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="closeDialog">取 消</el-button>
          <el-button @click="enterDialog" type="primary">确 定</el-button>
        </div>
      </template>
    </el-dialog>
    <div class="tips">
      在资源权限中将此角色的资源权限清空 或者不包含创建者的角色 即可屏蔽此客户资源的显示
    </div>
  </div>
</template>

<script>
import {
  createExaCustomer,
  updateExaCustomer,
  deleteExaCustomer,
  getExaCustomer,
  getExaCustomerList,
} from "@/api/customer";
import { formatTimeToStr } from "@/utils/date";
import { infoList } from "@/mixins/infoList";
import { ref, getCurrentInstance, reactive } from "vue";

export default {
  name: "Customer",
  setup() {
    const { ctx } = getCurrentInstance();
    const { tableInfo, handleSizeChange, handleCurrentChange, getTableData } = infoList(
      getExaCustomerList
    );
    const dialogFormVisible = ref(false);
    const visible = ref(false);
    const type = ref("");
    const form = reactive({
      ID: 0,
      customerName: "",
      customerPhoneData: "",
    });
    const formatDate = (time) => {
      if (time != null && time != "") {
        var date = new Date(time);
        return formatTimeToStr(date, "yyyy-MM-dd hh:mm:ss");
      } else {
        return "";
      }
    };
    const updateCustomerFunc = async (row) => {
      const res = await getExaCustomer({ ID: row.ID });
      type.value = "update";
      if (res.code == 0) {
        Object.assign(form, res.data.customer);
        dialogFormVisible.value = true;
      }
    };
    const closeDialog = () => {
      dialogFormVisible.value = false;
      Object.assign(form, {
        ID: 0,
        customerName: "",
        customerPhoneData: "",
      });
    };
    const deleteCustomerFunc = async (row) => {
      visible.value = false;
      const res = await deleteExaCustomer({ ID: row.ID });
      if (res.code == 0) {
        ctx.$message({
          type: "success",
          message: "删除成功",
        });
        getTableData();
      }
    };
    const enterDialog = async () => {
      let res;
      switch (type.value) {
        case "create":
          res = await createExaCustomer(form);
          break;
        case "update":
          res = await updateExaCustomer(form);
          break;
        default:
          res = await createExaCustomer(form);
          break;
      }

      if (res.code == 0) {
        closeDialog();
        getTableData();
      }
    };
    const openDialog = () => {
      type.value = "create";
      dialogFormVisible.value = true;
    };
    getTableData();
    return {
      tableInfo,
      handleSizeChange,
      handleCurrentChange,
      dialogFormVisible,
      visible,
      type,
      form,
      formatDate,
      updateCustomerFunc,
      closeDialog,
      deleteCustomerFunc,
      enterDialog,
      openDialog,
    };
  },
};
</script>

<style></style>
