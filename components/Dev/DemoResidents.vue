<template>
  <UCard
  >
    <template #header>
      <div class="flex flex-col justify-start md:flex-row md:gap-1 md:justify-between md:items-center">
        <div>DEMO TENANCIES</div>
        <div><UIcon name="i-heroicons-shield-exclamation"/><span class="text-xs border-2"> Look here for more info about this component: /supabase/seed.sql</span></div>
        <a v-if="showInbucket" href="http://localhost:54324/monitor">Inbucket Monitor</a>
      </div>
    </template>
    <UTable
      :rows="residents"
      :columns="[
        {key: 'actions'},
        {key: 'email', label: 'Email', sortable: true},
        {key: 'status', label: 'Status', sortable: true},
        {key: 'tenantName', label: 'Tenant', sortable: true},
      ]"
      :sort="{ column: 'email', direction: 'asc'}"
    >
      <template #actions-data="{ row }">
        <UButton @click="handleLogin(row)">Login</UButton>
      </template>
    </UTable>
  </UCard>
</template>

<script lang="ts" setup>
  const supabase = useSupabaseClient()
  const residents = ref([])
  const loadResidents = async () => {
    const result = await GqlDemoResidents()
    residents.value = result.demoProfileResidencies.nodes || []
  }
  loadResidents()

  const handleLogin = async (resident: any) => {
    const { error } = await supabase.auth.signInWithOtp({
      email: resident.email,
      options: {
        emailRedirectTo: `${window.origin}/authenticated`,
      }
    })
    if (error) {
      alert(error.message)
    } else {
      alert('Check your email inbox for the magic link!')
      if (process.env.environment === 'development') {
        navigateTo('http://localhost:54324/monitor', {external: true})
      }
    }
  }

  const showInbucket = computed(() => {
    return process.env.NODE_ENV === 'development'
  })
</script>