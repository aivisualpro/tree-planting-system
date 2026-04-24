import { serverSupabaseClient } from '#supabase/server';

export default defineEventHandler(async (event) => {
  const type = getRouterParam(event, 'type');
  const client = await serverSupabaseClient<any>(event);
  const query = getQuery(event);

  let data: any[] = [];
  let columns: any[] = [];
  let filename = `export-${type}-${Date.now()}.xlsx`;

  try {
    if (type === 'visits') {
      const { data: visits } = await client
        .from('visits')
        .select('*, countries(name_en), communities(name_en), activities(name_en)')
        .limit(10000); // Handle streaming in a real scenario with pagination

      data = visits || [];
      columns = [
        { header: 'Visit ID', key: 'id', width: 40 },
        { header: 'Country', key: 'countries.name_en', width: 20 },
        { header: 'Community', key: 'communities.name_en', width: 20 },
        { header: 'Activity', key: 'activities.name_en', width: 25 },
        { header: 'Trees Planted', key: 'total_trees_planted', width: 15 },
        { header: 'Status', key: 'status', width: 15 },
        { header: 'Date', key: 'created_at', width: 25 },
      ];
      
      // Flatten nested data for Excel
      data = data.map(v => ({
        ...v,
        'countries.name_en': v.countries?.name_en,
        'communities.name_en': v.communities?.name_en,
        'activities.name_en': v.activities?.name_en,
      }));
    } else if (type === 'users') {
      const { data: profiles } = await client.from('profiles').select('*');
      data = profiles || [];
      columns = [
        { header: 'User ID', key: 'id', width: 40 },
        { header: 'Role', key: 'role', width: 15 },
        { header: 'Language', key: 'language_code', width: 10 },
        { header: 'WhatsApp', key: 'whatsapp', width: 20 },
        { header: 'Created At', key: 'created_at', width: 25 },
      ];
    }

    const buffer = await generateExcel(data, columns, type?.toUpperCase());

    setResponseHeader(event, 'Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    setResponseHeader(event, 'Content-Disposition', `attachment; filename="${filename}"`);
    
    return buffer;
  } catch (error: any) {
    console.error('Export error:', error);
    throw createError({
      statusCode: 500,
      statusMessage: 'Failed to generate export',
    });
  }
});
