import React, { useEffect, useState } from 'react';
import { Server } from '@/api/server/getServer';
import getServers from '@/api/getServers';
import ServerRow from '@/components/dashboard/ServerRow';
import Spinner from '@/components/elements/Spinner';
import PageContentBlock from '@/components/elements/PageContentBlock';
import useFlash from '@/plugins/useFlash';
import { useStoreState } from 'easy-peasy';
import { usePersistedState } from '@/plugins/usePersistedState';
import Switch from '@/components/elements/Switch';
import tw from 'twin.macro';
import useSWR from 'swr';
import { PaginatedResult } from '@/api/http';
import Pagination from '@/components/elements/Pagination';
import { useLocation } from 'react-router-dom';
import Card from '@/reviactyl/ui/Card';
import Title from '@/reviactyl/ui/Title';
import { EmojiSadIcon } from '@heroicons/react/solid';
import { useTranslation } from 'react-i18next';

export default () => {
    const { t } = useTranslation('dashboard/index');
    const { search } = useLocation();
    const defaultPage = Number(new URLSearchParams(search).get('page') || '1');

    const [page, setPage] = useState(!isNaN(defaultPage) && defaultPage > 0 ? defaultPage : 1);
    const { clearFlashes, clearAndAddHttpError } = useFlash();
    const user = useStoreState((state) => state.user.data!);
    const rootAdmin = user.rootAdmin;
    const [showOnlyAdmin, setShowOnlyAdmin] = usePersistedState(`${user.uuid}:show_all_servers`, false);

    const { data: servers, error } = useSWR<PaginatedResult<Server>>(
        ['/api/client/servers', showOnlyAdmin && rootAdmin, page],
        () => getServers({ page, type: showOnlyAdmin && rootAdmin ? 'admin' : undefined })
    );

    useEffect(() => {
        if (!servers) return;
        if (servers.pagination.currentPage > 1 && !servers.items.length) {
            setPage(1);
        }
    }, [servers?.pagination.currentPage]);

    useEffect(() => {
        window.history.replaceState(null, document.title, `/${page <= 1 ? '' : `?page=${page}`}`);
    }, [page]);

    useEffect(() => {
        if (error) clearAndAddHttpError({ key: 'dashboard', error });
        if (!error) clearFlashes('dashboard');
    }, [error]);

    return (
        <PageContentBlock className='pr-2' title={t('title')} showFlashKey={'dashboard'}>
            <div className='flex items-center justify-between py-4'>
                <div>
                    <Title className='text-4xl'>{t('title')}</Title>
                </div>
                {rootAdmin && (
                    <div className='flex items-center space-x-2'>
                        <p className='uppercase text-xs text-gray-400'>
                            {showOnlyAdmin ? t('other-servers') : t('your-servers')}
                        </p>
                        <Switch
                            name={'show_all_servers'}
                            defaultChecked={showOnlyAdmin}
                            onChange={() => setShowOnlyAdmin((s) => !s)}
                        />
                    </div>
                )}
            </div>
            {!servers ? (
                <Spinner centered size={'large'} />
            ) : (
                <div className='grid lg:grid-cols-2 gap-3'>
                    <Pagination data={servers} onPageSelect={setPage}>
                        {({ items }) =>
                            items.length > 0 ? (
                                items.map((server, index) => (
                                    <ServerRow
                                        key={server.uuid}
                                        server={server}
                                        css={index > 0 ? tw`mt-2` : undefined}
                                    />
                                ))
                            ) : (
                                <Card css={tw`col-span-1 lg:col-span-2`}>
                                    <p className='flex justify-center text-center text-sm text-gray-400'>
                                        <EmojiSadIcon className='w-5 h-5 mr-1' />{' '}
                                        {showOnlyAdmin ? t('no-other-servers') : t('no-servers')}
                                    </p>
                                </Card>
                            )
                        }
                    </Pagination>
                </div>
            )}

            {/* BAGIAN TOMBOL PREMIUM & CP (VERSI BERSIH TANPA CHAT) */}
            <div className='flex flex-col items-center justify-center mt-12 mb-8 space-y-4'>
                <a 
                    href="https://wa.me/6283109105308?text=Halo+Bang+Iboy,+saya+mau+order+Premium" 
                    target="_blank" 
                    rel="noreferrer"
                    className='group flex items-center space-x-4 bg-gray-800/60 hover:bg-gray-700/80 text-white px-6 py-3 rounded-2xl font-bold border border-gray-700 hover:border-cyan-500 shadow-xl transition-all'
                >
                    <img 
                        src="https://files.catbox.moe/ieo9o2.jpg" 
                        alt="IboyCloud" 
                        crossOrigin="anonymous"
                        className='w-10 h-10 rounded-full border-2 border-cyan-400 object-cover' 
                    />
                    <div className='flex flex-col items-start pr-4 leading-tight'>
                        <span className='text-[10px] text-cyan-400 uppercase tracking-widest font-black'>Premium Services</span>
                        <span className='text-base group-hover:text-cyan-100 transition-colors'>Buy Panel Premium</span>
                    </div>
                </a>

                <div className='flex items-center space-x-2 text-[11px] text-gray-500 bg-gray-900/40 px-4 py-1.5 rounded-full border border-gray-800/50'>
                    <span>Contact Person:</span>
                    <a href="https://wa.me/6283109105308" className='text-cyan-500 hover:text-cyan-300 font-bold'>@iboycloud</a>
                </div>
            </div>
        </PageContentBlock>
    );
};
