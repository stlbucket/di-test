<template>
  <UCard>
    <template #header>
      <h1 class="Home Page">Function Bucket Proto</h1>
      <p>This is a prototype instance - all data is subject to removal at any time.</p>
      <p v-if="isDemoMode">Since DEMO_MODE is enabled, the below users can be quickly logged in.</p>
    </template>
    <DemoResidents v-if="isDemoMode" />
  </UCard>
</template>

<script lang="ts" setup>
const isDemoMode = computed(() => {
  return useRuntimeConfig().public.DEMO_MODE
})
</script>
