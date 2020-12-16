<template>
  <div>
    <el-form :model="formData" label-position="right" label-width="80px">
      <el-form-item label="请假原因:">
        <el-input v-model="formData.cause" clearable placeholder="请输入"></el-input>
      </el-form-item>

      <el-form-item label="开始时间:">
        <el-date-picker
          type="date"
          placeholder="选择日期"
          v-model="formData.startTime"
          clearable
        ></el-date-picker>
      </el-form-item>

      <el-form-item label="结束时间:">
        <el-date-picker
          type="date"
          placeholder="选择日期"
          v-model="formData.endTime"
          clearable
        ></el-date-picker>
      </el-form-item>
      <el-form-item>
        <el-button v-if="wf.clazz == 'start'" @click="start" type="primary"
          >启动</el-button
        >
        <el-button v-if="wf.clazz == 'userTask'" @click="complete('yes')" type="primary"
          >同意</el-button
        >
        <el-button v-if="wf.clazz == 'userTask'" @click="complete('no')" type="primary"
          >拒绝</el-button
        >
        <el-button @click="back" type="primary">返回</el-button>
      </el-form-item>
    </el-form>
  </div>
</template> 

<script>
import { startWorkflow, completeWorkflowMove } from "@/api/workflowProcess";
import { reactive, getCurrentInstance,computed } from "vue";
import { useStore } from "vuex";
import { useRouter } from "vue-router";
export default {
  name: "ExaWfLeave",
  props: {
    business: {
      type: Object,
      default: function () {
        return null;
      },
    },
    wf: {
      type: Object,
      default: function () {
        return {};
      },
    },
    workflowMoveID: {
      type: Number,
      default: 0,
    },
  },
  setup(props) {
    const { ctx } = getCurrentInstance();
    const store = useStore();
    const router = useRouter();
    const formData = reactive({
      ID: 0,
      CreatedAt:undefined,
      UpdatedAt:undefined,
      cause: "",
      startTime: new Date(),
      endTime: new Date(),
    });

    const canShow = computed(() => {
      if (props.wf.assignType == "user") {
        if (props.wf.assginValue.indexOf("," + userInfo.value.ID + ",") > 0) {
          return true;
        } else {
          return false;
        }
      } else if (props.wf.assign_type == "authority") {
        if (props.wf.assginValue.indexOf("," + userInfo.value.authorityId + ",") > 0) {
          return true;
        } else {
          return false;
        }
      }
      return true;
    });
    const userInfo = computed(() => store.getters["user/userInfo"]);
    const start = async () => {
      const res = await startWorkflow({
        business: formData,
        wf: {
          workflowMoveID: props.workflowMoveID,
          businessId: 0,
          businessType: "leave",
          workflowProcessID: props.wf.workflowProcessID,
          workflowNodeID: props.wf.id,
          promoterID: userInfo.value.ID,
          operatorID: userInfo.value.ID,
          action: "create",
          param: "",
        },
      });
      if (res.code == 0) {
        ctx.$message({
          type: "success",
          message: "启动成功",
        });
        back();
      }
    };
    const complete = async (param) => {
      const res = await completeWorkflowMove({
        business: formData,
        wf: {
          workflowMoveID: props.workflowMoveID,
          businessID: formData.ID,
          businessType: "leave",
          workflowProcessID: props.wf.workflowProcessID,
          workflowNodeID: props.wf.id,
          promoterID: userInfo.value.ID,
          operatorID: userInfo.value.ID,
          action: "complete",
          param: param,
        },
      });
      if (res.code == 0) {
        ctx.$message({
          type: "success",
          message: "提交成功",
        });
        back();
      }
    };
    const back = () => {
      router.go(-1);
    };

    if (props.business) {
      Object.assign(formData, props.business);
    }
    return {
      formData,
      canShow,
      userInfo,
      start,
      complete,
      back,
    };
  },
};
</script>

<style></style>
