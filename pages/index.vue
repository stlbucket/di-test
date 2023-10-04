<template>
  <UCard>
    <template #header>
      <h1 class="Home Page">Function Bucket Proto</h1>
    </template>
    <p>This is a prototype instance - all data is subject to removal at any time.</p>
    <NuxtLink v-if="isDemoMode" to="/demo-residents">Demo Residents</NuxtLink> 
  </UCard>
</template>

<script lang="ts" setup>
const isDemoMode = computed(() => {
  return useRuntimeConfig().public.DEMO_MODE
})
</script>
