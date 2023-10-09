<template>
  <UTable
    :rows="residents"
    :columns="columns"
    :sort="{ column: 'tenantName', direction: 'asc' }"
    :sortable="!disableSort"
    class="grow"
  >
    <template #email-data="{ row }">
      <NuxtLink :to="`/admin/app-tenant-residencies/${row.id}`">{{ row.email }}</NuxtLink>
    </template>
    <template #assume-data="{ row }">
      <UButton @click="onAssume(row)">{{ String(row.status).toLowerCase() === 'active' ? 'Refresh' : 'Assume' }}</UButton>
    </template>
    <template #decline-data="{ row }">
      <UButton v-if="String(row.status).toLowerCase() === 'invited'" @click="onDecline(row)" color="red">Decline</UButton>
      <div v-else></div>
    </template>
  </UTable>
</template>

<script lang="ts" setup>
  const props = defineProps<{
    residents: Resident[]
    rowActionName?: string
    showEmail?: boolean
    showDisplayName?: boolean
    disableSort?: boolean
    showAssume?: boolean
    showDecline?: boolean
  }>()

  const emit = defineEmits<{
    (e: 'assume', row: Resident): void
    (e: 'decline', row: Resident): void
  }>()

  const onAssume = async (row: Resident) => {
    emit('assume', row)
  }

  const onDecline = async (row: Resident) => {
    emit('decline', row)
  }

  const columns = computed(()=>{
    return [
      {key: 'assume'},
      {key: 'displayName', label: 'Display Name', sortable: !props.disableSort},
      {key: 'email', label: 'Email', sortable: !props.disableSort},
      {key: 'status', label: 'Status', sortable: !props.disableSort},
      {key: 'tenantName', label: 'Tenant', sortable: !props.disableSort},
      {key: 'decline'},
    ]
    .filter(c => c.key !== 'displayName' || props.showDisplayName )
    .filter(c => c.key !== 'email'  || props.showEmail)
    .filter(c => c.key !== 'assume'  || props.showAssume)
    .filter(c => c.key !== 'decline'  || props.showDecline)
  })

</script>