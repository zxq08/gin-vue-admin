<template>
  <div class="workflow-use">
    <div style="padding:10px 20px">
      <el-steps
        :active="moves.length-1"
        :process-status="processStatus"
        finish-status="finish"
        align-center
      >
        <el-step v-for="(item, key) in moves" :key="key">
          <div slot="title">{{ item.workflowNode.label }}</div>
          <div slot="description">
            <div>节点说明:{{ item.workflowNode.description }}</div>
            <div v-if="item.operator.nickName">操作人:{{ item.operator.nickName }}</div>
            <div>操作参数:{{ item.param||'无参数' }}</div>
          </div>
        </el-step>
      </el-steps>
    </div>
    <WorkflowInfo
      v-if="done"
      :wf="node"
      :business="business"
      :move="move"
      :workflowMoveID="$route.query.workflowMoveID"
    ></WorkflowInfo>
  </div>
</template>
<script>
import {
  findWorkflowStep,
  getWorkflowMoveByID
} from "@/api/workflowProcess.js";
import { ref, reactive, getCurrentInstance, computed, createTextVNode } from "vue";
import { useRoute } from "vue-router";
export default {
  name: "WorklowUse",
  setup() {
    const { appContext, ctx } = getCurrentInstance();

    const route = useRoute();
    const done = ref(false);
    const business = reactive({});
    const node = reactive({});
    const moves = reactive([]);
    const move = reactive({});
    const workflow = reactive({});

    const processStatus = computed(() => {
      const node = moves[moves.length - 1];
      if (node && node.workflowNode.clazz == "end") {
        if (node.workflowNode.success) {
          return "success";
        } else {
          return "error";
        }
      } else {
        return "process";
      }
    });
    
    const createDone = async () => {
      let path = "";
      if (node.view) {
        path = node.view;
      } else {
        path = workflow.view;
      }
      const compent = await import("@/"+path)
      appContext.components.WorkflowInfo = compent.default
      console.log(appContext.components)
      done.value = true;
    };
    const initWFU = async () => {
      const workflowId = route.query.workflowId;
      const workflowMoveID = route.query.workflowMoveID;
      if (workflowId) {
        const res = await findWorkflowStep({ id: workflowId });
        if (res.code == 0) {
          Object.assign(workflow, res.data.workflow);
          Object.assign(node, res.data.workflow.nodes[0]);
          createDone();
        }
      } else if (workflowMoveID) {
        const res = await getWorkflowMoveByID({ id: workflowMoveID });
        if (res.code == 0) {
          Object.assign(business, res.data.business);
          Object.assign(workflow, res.data.move.workflowProcess);
          Object.assign(node, res.data.move.workflowNode);
          Object.assign(move, res.data.move);
          Object.assign(moves, res.data.moves);
          createDone();
          
        }
      }
    };
    initWFU();
    return {
      done,
      business,
      node,
      moves,
      move,
      processStatus,
      createDone
    }
  },
};
</script>