<template>
  <div>
    <div class="search-term">
      <el-form :inline="true" :model="tableInfo.searchInfo" class="demo-form-inline">
        <el-form-item label="流程名称">
          <el-input placeholder="搜索条件" v-model="tableInfo.searchInfo.name"></el-input>
        </el-form-item>
        <el-form-item label="流程标题">
          <el-input placeholder="搜索条件" v-model="tableInfo.searchInfo.label"></el-input>
        </el-form-item>
        <el-form-item>
          <el-button @click="onSubmit" type="primary">查询</el-button>
        </el-form-item>
        <el-form-item>
          <el-popover placement="top" v-model="deleteVisible" width="160">
            <p>确定要删除吗？</p>
            <div style="text-align: right; margin: 0">
              <el-button @click="deleteVisible = false" size="mini" type="text">取消</el-button>
              <el-button @click="onDelete" size="mini" type="primary">确定</el-button>
            </div>
            <template #reference>
              <el-button icon="el-icon-delete" size="mini" type="danger">批量删除</el-button>
            </template>
          </el-popover>
        </el-form-item>
      </el-form>
    </div>
    <el-table
      :data="tableInfo.tableData"
      @selection-change="handleSelectionChange"
      border
      ref="multipleTable"
      stripe
      style="width: 100%"
      tooltip-effect="dark"
    >
      <el-table-column type="selection" width="55"></el-table-column>
      <el-table-column label="日期" width="180">
        <template #default="scope">{{ formatDate(scope.row.CreatedAt)}}</template>
      </el-table-column>
      <el-table-column label="流程名称" prop="name" width="120"></el-table-column>

      <el-table-column label="分类" prop="category" width="120"></el-table-column>

      <el-table-column label="类型" prop="clazz" width="120"></el-table-column>

      <el-table-column label="流程标题" prop="label" width="120"></el-table-column>

      <el-table-column label="是否隐藏图标" prop="hideIcon" width="120">
        <template #default="scope">
          {{ formatBoolean(scope.row.hideIcon) }}
        </template>
      </el-table-column>

      <el-table-column label="详细介绍" prop="description" width="120"></el-table-column>

      <el-table-column label="按钮组">
        <template #default="scope">
          <el-button class="table-button" @click="useWorkflowProcess(scope.row)" size="success">启动</el-button>
          <el-button
            class="table-button"
            @click="updateWorkflowProcess(scope.row)"
            size="small"
            type="primary"
          >变更</el-button>
          <el-button
            class="table-button"
            @click="viewWorkflowProcess(scope.row)"
            size="small"
            type="warning"
          >查看</el-button>
          <el-popover placement="top" width="160" v-model="scope.row.visible">
            <p>确定要删除吗？</p>
            <div style="text-align: right; margin: 0">
              <el-button size="mini" type="text" @click="scope.row.visible = false">取消</el-button>
              <el-button type="primary" size="mini" @click="deleteWorkflowProcessFun(scope.row)">确定</el-button>
            </div>
            <template #reference>
              <el-button type="danger" icon="el-icon-delete" size="mini">删除</el-button>
            </template>
          </el-popover>
        </template>
      </el-table-column>
    </el-table>

    <el-pagination
      :current-page="tableInfo.page"
      :page-size="tableInfo.pageSize"
      :page-sizes="[10, 30, 50, 100]"
      :style="{ float: 'right', padding: '20px' }"
      :total="tableInfo.total"
      @current-change="handleCurrentChange"
      @size-change="handleSizeChange"
      layout="total, sizes, prev, pager, next, jumper"
    ></el-pagination>
  </div>
</template>

<script>
import {
  deleteWorkflowProcess,
  deleteWorkflowProcessByIds,
  getWorkflowProcessList
} from "@/api/workflowProcess"; //  此处请自行替换地址
import { formatTimeToStr } from "@/utils/date";
import { infoList } from "@/mixins/infoList";
import { ref, reactive, getCurrentInstance } from "vue";
import { useRouter } from "vue-router";
export default {
  name: "WorkflowProcess",
  setup() {
    const router = useRouter();
    const { ctx } = getCurrentInstance();
    const {
      tableInfo,
      handleSizeChange,
      handleCurrentChange,
      getTableData
    } = infoList(getWorkflowProcessList);
    const dialogFormVisible = ref(false);
    const visible = ref(false);
    const deleteVisible = ref(false);
    const multipleSelection = reactive([]);

    const formatDate = time => {
      if (time != null && time != "") {
        var date = new Date(time);
        return formatTimeToStr(date, "yyyy-MM-dd hh:mm:ss");
      } else {
        return "";
      }
    };
    const formatBoolean = bool => {
      if (bool != null) {
        return bool ? "是" : "否";
      } else {
        return "";
      }
    };

    //条件搜索前端看此方法
    const onSubmit = () => {
      tableInfo.page = 1;
      tableInfo.pageSize = 10;
      if (tableInfo.searchInfo.hideIcon == "") {
        tableInfo.searchInfo.hideIcon = null;
      }
      getTableData();
    };
    const handleSelectionChange = val => {
      multipleSelection.length = 0;
      Object.assign(multipleSelection, val);
    };
    const onDelete = async () => {
      const ids = [];
      multipleSelection &&
        multipleSelection.map(item => {
          ids.push(item.id);
        });
      const res = await deleteWorkflowProcessByIds({ ids });
      if (res.code == 0) {
        ctx.$message({
          type: "success",
          message: "删除成功"
        });
        deleteVisible.value = false;
        getTableData();
      }
    };
    const updateWorkflowProcess = row => {
      router.push({
        name: "workflowCreate",
        query: {
          id: row.id,
          type: "edit"
        }
      });
    };
    const useWorkflowProcess = row => {
      router.push({
        name: "workflowUse",
        query: {
          workflowId: row.id
        }
      });
    };
    const viewWorkflowProcess = row => {
      router.push({
        name: "workflowCreate",
        query: {
          id: row.id,
          type: "view"
        }
      });
    };
    const deleteWorkflowProcessFun = async row => {
      visible.value = false;
      const res = await deleteWorkflowProcess({ id: row.id });
      if (res.code == 0) {
        ctx.$message({
          type: "success",
          message: "删除成功"
        });
        getTableData();
      }
    };
    const openDialog = () => {
      dialogFormVisible.value = true;
    };

    getTableData();
    return {
      tableInfo,
      handleSizeChange,
      handleCurrentChange,
      dialogFormVisible,
      visible,
      deleteVisible,
      multipleSelection,
      formatDate,
      formatBoolean,
      onSubmit,
      handleSelectionChange,
      onDelete,
      updateWorkflowProcess,
      useWorkflowProcess,
      viewWorkflowProcess,
      deleteWorkflowProcessFun,
      openDialog
    };
  }
};
</script>

<style>
</style>