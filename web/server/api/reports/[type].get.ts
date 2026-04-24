import { serverSupabaseClient } from '#supabase/server';

export default defineEventHandler(async (event) => {
  const type = getRouterParam(event, 'type');
  const query = getQuery(event);
  const client = await serverSupabaseClient<any>(event);

  let html = '';
  let filename = `report-${type}-${Date.now()}.pdf`;

  try {
    if (type === 'monthly-country') {
      const countryId = query.countryId as string;
      const monthYear = (query.monthYear as string) || new Date().toLocaleString('en-US', { month: 'long', year: 'numeric' });

      // Fetch country data
      const { data: country } = await client.from('countries').select('*').eq('id', countryId).single();
      if (!country) throw createError({ statusCode: 404, statusMessage: 'Country not found' });

      // Fetch aggregated stats (mocking for now, in real app would use RPC or complex query)
      const { data: stats } = await client.rpc('get_country_monthly_stats', { 
        p_country_id: countryId, 
        p_month_year: monthYear 
      });

      html = getMonthlyCountryReportTemplate({
        countryName: country.name_en,
        monthYear: monthYear,
        totalTrees: stats?.total_trees || 0,
        totalVisits: stats?.total_visits || 0,
        topSpecies: stats?.top_species || [
          { name: 'Mango', scientificName: 'Mangifera indica', count: 0, percentage: 0 }
        ]
      });
    } 
    else if (type === 'visit') {
      const visitId = query.visitId as string;
      const { data: visit, error: visitError } = await client
        .from('visits')
        .select(`
          *,
          countries(name_en),
          communities(name_en),
          subwatersheds(name_en),
          activities(name_en)
        `)
        .eq('id', visitId)
        .single();

      if (!visit) throw createError({ statusCode: 404, statusMessage: 'Visit not found' });

      const { data: media } = await client.from('visit_media').select('*').eq('visit_id', visitId);

      html = getVisitReportTemplate({
        visitId: visit.id,
        countryName: visit.countries.name_en,
        communityName: visit.communities?.name_en || 'N/A',
        subwatershedName: visit.subwatersheds?.name_en || 'N/A',
        activityName: visit.activities.name_en,
        totalTrees: visit.total_trees_planted,
        media: media?.map(m => ({ 
          url: `${process.env.SUPABASE_URL}/storage/v1/object/public/visit-media/${m.storage_path}` 
        })) || []
      });
      filename = `visit-report-${visitId}.pdf`;
    }

    const pdf = await generatePdf(html);

    setResponseHeader(event, 'Content-Type', 'application/pdf');
    setResponseHeader(event, 'Content-Disposition', `attachment; filename="${filename}"`);
    
    return pdf;
  } catch (error: any) {
    console.error('Report generation error:', error);
    throw createError({
      statusCode: error.statusCode || 500,
      statusMessage: error.statusMessage || 'Internal Server Error',
    });
  }
});
